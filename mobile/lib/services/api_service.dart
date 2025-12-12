import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Pastikan package ini ada di pubspec.yaml

import '../../models/api_response.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../utils/global_context.dart';
import '../utils/global_error_handler.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
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

  // --- CORE HELPER (Mencegah Redudansi) ---
  Future<ApiResponse<T>> _performRequest<T>(
    Future<http.Response> Function() requestFn,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await requestFn().timeout(const Duration(seconds: 30));

      // Handle Empty Response
      if (response.body.isEmpty) {
        throw FormatException('Empty response from server');
      }

      // Handle JSON Format
      final trimmed = response.body.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        throw FormatException('Invalid JSON format: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Handle Success Status (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null
              ? fromJson(data['data'])
              : null,
          statusCode: response.statusCode,
          pagination: data['pagination'], // Handle pagination generic
        );
      } else {
        // Handle API Error
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

  // --- PUBLIC METHODS (Sekarang jauh lebih ringkas) ---

  Future<ApiResponse<T>> get<T>(
      String endpoint, T Function(dynamic)? fromJson) async {
    return _performRequest(
      () async => http.get(Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders()),
      fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> body,
      T Function(dynamic)? fromJson) async {
    return _performRequest(
      () async => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
      fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(String endpoint, Map<String, dynamic> body,
      T Function(dynamic)? fromJson) async {
    return _performRequest(
      () async => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ),
      fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
      String endpoint, T Function(dynamic)? fromJson) async {
    return _performRequest(
      () async => http.delete(Uri.parse('$baseUrl$endpoint'),
          headers: await _getHeaders()),
      fromJson,
    );
  }

  Future<ApiResponse<T>> multipartPost<T>(
    String endpoint,
    Map<String, String> fields,
    List<int> fileBytes,
    String fileName,
    String fieldName, {
    T Function(dynamic)? fromJson,
  }) async {
    // Multipart butuh penanganan khusus stream, tapi error handlingnya sama
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final uri = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      fields.forEach((key, value) => request.fields[key] = value);

      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      // Kita bungkus response stream ke http.Response biasa agar bisa masuk _performRequest logika
      // Tapi karena _performRequest menerima closure request, kita gunakan logika manual sedikit di sini
      // agar tidak merombak _performRequest terlalu jauh.

      final data = jsonDecode(responseBody);
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return ApiResponse<T>(
          success: data['success'] ?? true,
          message: data['message'] ?? 'Success',
          data: data['data'] != null && fromJson != null
              ? fromJson(data['data'])
              : null,
          statusCode: streamedResponse.statusCode,
        );
      } else {
        throw Exception(data['message'] ?? 'Request failed');
      }
    } catch (e) {
      if (GlobalContext.currentContext != null) GlobalErrorHandler.handle(e);
      return ApiResponse<T>(
          success: false, message: 'Upload error: $e', statusCode: 500);
    }
  }
}
