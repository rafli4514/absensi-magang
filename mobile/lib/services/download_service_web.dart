import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Web-specific download implementation using browser APIs
class DownloadService {
  /// Download file using browser download mechanism
  Future<void> downloadFile({
    required String url,
    required String filename,
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('🌐 [WEB] Downloading: $url');
      
      // 1. Fetch file data with timeout
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Download timeout after 30s'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Download failed with status ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // 2. Create Blob from response bytes
      final blob = html.Blob([response.bodyBytes]);
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // 3. Create temporary anchor element and trigger download
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', filename)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      
      // 4. Cleanup
      anchor.remove();
      html.Url.revokeObjectUrl(blobUrl);
      
      debugPrint('✅ [WEB] Download triggered: $filename');
    } catch (e) {
      debugPrint('❌ [WEB] Download error: $e');
      rethrow;
    }
  }
}

DownloadService getDownloadService() => DownloadService();
