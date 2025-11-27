import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/api_response.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 
        'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, 
    T Function(dynamic)? fromJson
  ) async {
    try {
      if (responseBody.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = responseBody.trim();

      // Validate JSON structure
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        throw FormatException('Invalid JSON format');
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null 
              ? fromJson(data['data']) 
              : null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, 
    Map<String, dynamic> body, 
    T Function(dynamic)? fromJson
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null 
              ? fromJson(data['data']) 
              : null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  // Tambahkan method PUT dan DELETE jika diperlukan
  Future<ApiResponse<T>> put<T>(
    String endpoint, 
    Map<String, dynamic> body, 
    T Function(dynamic)? fromJson
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null 
              ? fromJson(data['data']) 
              : null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(dynamic)? fromJson
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null 
              ? fromJson(data['data']) 
              : null,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }
}
