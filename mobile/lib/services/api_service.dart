import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/api_response.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Safe JSON parsing with validation
  dynamic _parseResponse(String responseBody) {
    try {
      if (responseBody.isEmpty) {
        throw FormatException('Empty response from server');
      }

      final trimmed = responseBody.trim();

      // Validate JSON structure
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
        throw FormatException('Invalid JSON format');
      }

      return jsonDecode(trimmed);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders())
          .timeout(const Duration(seconds: 30));

      final data = _parseResponse(response.body);
      return ApiResponse.fromJson(data, fromJson);
    } on FormatException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid server response',
        statusCode: 500,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = _parseResponse(response.body);
      return ApiResponse.fromJson(data, fromJson);
    } on FormatException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid server response',
        statusCode: 500,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }
}
