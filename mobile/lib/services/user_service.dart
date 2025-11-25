import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class UserService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  static Future<ApiResponse<List<User>>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (role != null) 'role': role,
        if (isActive != null) 'isActive': isActive.toString(),
      };

      final uri = Uri.parse('$baseUrl/users').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<User> users = (data['data'] as List)
            .map((item) => User.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          data: users,
          message: data['message'],
          pagination: data['pagination'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve users',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve users: $e',
      );
    }
  }

  // Get user by ID
  static Future<ApiResponse<User>> getUserById(String id) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.get(
        '/users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          data: user,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to retrieve user',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to retrieve user: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve user: $e',
      );
    }
  }

  // Create user
  static Future<ApiResponse<User>> createUser({
    required String username,
    required String password,
    String role = 'user',
    bool isActive = true,
  }) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.post(
        '/users',
        data: {
          'username': username,
          'password': password,
          'role': role,
          'isActive': isActive,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          data: user,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to create user',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to create user: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to create user: $e');
    }
  }

  // Update user
  static Future<ApiResponse<User>> updateUser({
    required String id,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (password != null) data['password'] = password;
      if (role != null) data['role'] = role;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put(
        '/users/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          data: user,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to update user',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to update user: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to update user: $e');
    }
  }

  // Delete user
  static Future<ApiResponse<void>> deleteUser(String id) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.delete(
        '/users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        return ApiResponse(success: true, message: response.data['message']);
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to delete user',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to delete user: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to delete user: $e');
    }
  }

  // Toggle user status
  static Future<ApiResponse<User>> toggleUserStatus(String id) async {
    try {
      final token = await StorageService.getString(AppConstants.tokenKey);
      final response = await _dio.patch(
        '/users/$id/toggle-status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        return ApiResponse(
          success: true,
          data: user,
          message: response.data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to toggle user status',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ??
            'Failed to toggle user status: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to toggle user status: $e',
      );
    }
  }
}
