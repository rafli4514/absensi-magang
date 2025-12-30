import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SettingsService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Cache ringan untuk settings selama sesi aplikasi
  static Map<String, dynamic>? _cachedSettings;
  static DateTime? _cachedSettingsFetchedAt;

  // Get all settings
  static Future<ApiResponse<Map<String, dynamic>>> getSettings({
    bool forceRefresh = false,
  }) async {
    try {
      // Gunakan cache jika masih fresh (misal 5 menit) dan tidak dipaksa refresh
      if (!forceRefresh &&
          _cachedSettings != null &&
          _cachedSettingsFetchedAt != null) {
        final diff = DateTime.now().difference(_cachedSettingsFetchedAt!);
        if (diff.inMinutes < 5) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: _cachedSettings,
            message: 'Settings loaded from cache',
          );
        }
      }

      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.get(
        '/settings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['success'] == true) {
          final dataMap = Map<String, dynamic>.from(resData['data']);

          // Simpan ke cache
          _cachedSettings = dataMap;
          _cachedSettingsFetchedAt = DateTime.now();

          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: dataMap,
            message: resData['message'] ?? 'Settings loaded',
          );
        }
      }

      return ApiResponse(
        success: false,
        message: 'Gagal memuat pengaturan sistem',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // --- FIX: Method generateQRCode ditambahkan di sini ---
  static Future<ApiResponse<Map<String, dynamic>>> generateQRCode({
    String type = 'masuk',
  }) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);

      // Panggil endpoint backend /settings/qr/generate
      final response = await _dio.post(
        '/settings/qr/generate',
        queryParameters: {'type': type}, // Kirim tipe sebagai query param
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['success'] == true) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: Map<String, dynamic>.from(resData['data']),
            message: resData['message'] ?? 'QR Code generated',
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data?['message'] ?? 'Gagal membuat QR Code',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}
