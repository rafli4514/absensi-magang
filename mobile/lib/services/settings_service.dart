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
      // Gunakan cache jika masih fresh (misal 5 menit)
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

      if (response.data['success'] == true) {
        final data = Map<String, dynamic>.from(response.data['data']);
        _cachedSettings = data;
        _cachedSettingsFetchedAt = DateTime.now();

        return ApiResponse(
          success: true,
          data: data,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to retrieve settings',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to retrieve settings: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve settings: $e',
      );
    }
  }

  // Update settings
  static Future<ApiResponse<Map<String, dynamic>>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.put(
        '/settings',
        data: settings,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        // Setelah update, segarkan cache dengan data terbaru
        _cachedSettings =
            Map<String, dynamic>.from(response.data['data'] ?? {});
        _cachedSettingsFetchedAt = DateTime.now();

        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(response.data['data']),
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to update settings',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to update settings: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to update settings: $e',
      );
    }
  }

  // Generate QR Code
  static Future<ApiResponse<Map<String, dynamic>>> generateQRCode({
    String type = 'masuk',
  }) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.post(
        '/settings/generate-qr',
        queryParameters: {'type': type},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(response.data['data']),
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to generate QR code',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to generate QR code: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to generate QR code: $e',
      );
    }
  }

  // Validate QR Code
  static Future<ApiResponse<Map<String, dynamic>>> validateQRCode(
    String qrData,
  ) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.post(
        '/settings/validate-qr',
        data: {'qrData': qrData},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(response.data['data']),
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to validate QR code',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to validate QR code: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to validate QR code: $e',
      );
    }
  }
}
