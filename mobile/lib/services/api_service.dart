import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../models/api_response.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../utils/global_context.dart';
import '../utils/global_error_handler.dart';

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

  // --- GET METHOD ---
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
        // Handle Server Error (e.g. 401, 404, 500)
        final errorResponse = ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );

        if (GlobalContext.currentContext != null) {
          GlobalErrorHandler.handle(errorResponse);
        }

        return errorResponse;
      }
    } catch (e) {
      // Handle Exception (Network error, Timeout, Parsing error)
      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(e);
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // --- POST METHOD ---
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
        // Handle Server Error
        final errorResponse = ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );

        if (GlobalContext.currentContext != null) {
          GlobalErrorHandler.handle(errorResponse);
        }

        return errorResponse;
      }
    } catch (e) {
      // Handle Exception
      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(e);
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // --- PUT METHOD ---
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
        // Handle Server Error
        final errorResponse = ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );

        if (GlobalContext.currentContext != null) {
          GlobalErrorHandler.handle(errorResponse);
        }

        return errorResponse;
      }
    } catch (e) {
      // Handle Exception
      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(e);
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // --- DELETE METHOD ---
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
        // Handle Server Error
        final errorResponse = ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );

        if (GlobalContext.currentContext != null) {
          GlobalErrorHandler.handle(errorResponse);
        }

        return errorResponse;
      }
    } catch (e) {
      // Handle Exception
      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(e);
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // --- MULTIPART POST METHOD (File Upload) ---
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
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add file
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'), // Pastikan import http_parser
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      if (responseBody.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = responseBody.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        throw FormatException('Invalid JSON format');
      }

      final data = jsonDecode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null
              ? fromJson(data['data'])
              : null,
          statusCode: statusCode,
        );
      } else {
        // Handle Server Error
        final errorResponse = ApiResponse<T>(
          success: false,
          message: data['message'] ?? 'Request failed',
          statusCode: statusCode,
        );

        if (GlobalContext.currentContext != null) {
          GlobalErrorHandler.handle(errorResponse);
        }

        return errorResponse;
      }
    } catch (e) {
      // Handle Exception
      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(e);
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
