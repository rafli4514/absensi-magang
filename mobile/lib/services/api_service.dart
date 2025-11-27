import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../models/api_response.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // Create a singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = response.body.trim();

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
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = response.body.trim();
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
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = response.body.trim();
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
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.body.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = response.body.trim();
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
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Multipart request for file uploads
  Future<ApiResponse<T>> multipartPost<T>(
    String endpoint,
    Map<String, String> fields,
    List<int> fileBytes,
    String fileName,
    String fieldName, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final uri = Uri.parse('$baseUrl$endpoint');

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add file
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (responseBody.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = responseBody.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        throw FormatException('Invalid JSON format');
      }

      final data = jsonDecode(responseBody);

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
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
