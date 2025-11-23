import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../services/storage_service.dart';
import '../../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = AppConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic) fromJson) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> body, T Function(dynamic) fromJson) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}