import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

/// Mobile-specific download implementation (Android/iOS)
class DownloadService {
  /// Download file to device storage and open
  Future<void> downloadFile({
    required String url,
    required String filename,
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('📱 [MOBILE] Downloading: $url');
      
      // 1. Request storage permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try manageExternalStorage for Android 11+
          final manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // 2. Download file with timeout
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {},
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Download timeout after 60s'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Download failed with status ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // 3. Determine save directory
      Directory directory;
      if (Platform.isAndroid) {
        // Try public Downloads folder first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app's documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: Use app documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError('Platform not supported');
      }

      // 4. Write file to storage
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      debugPrint('✅ [MOBILE] Saved to: $filePath');

      // 5. Automatically open the file
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        debugPrint('📂 [MOBILE] File opened successfully');
      } else {
        debugPrint('⚠️ [MOBILE] Could not open file: ${result.message}');
      }
      
    } catch (e) {
      debugPrint('❌ [MOBILE] Download error: $e');
      rethrow;
    }
  }
}

DownloadService getDownloadService() => DownloadService();
