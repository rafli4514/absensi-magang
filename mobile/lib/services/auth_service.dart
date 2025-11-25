import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  static Future<ApiResponse<User>> register(
    String email,
    String password,
  ) async {
    try {
      print('🔄 [AUTH SERVICE] Attempting registration for: $email');

      final url = '${AppConstants.baseUrl}/auth/register';
      print('🌐 [AUTH SERVICE] URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
          'role': 'user',
        }),
      );

      print('📡 [AUTH SERVICE] Response Status: ${response.statusCode}');
      print('📡 [AUTH SERVICE] Response Body: ${response.body}');

      // Check jika response body kosong
      if (response.body.isEmpty) {
        print('❌ [AUTH SERVICE] Response body is empty!');
        return ApiResponse<User>(
          success: false,
          message: 'Empty response from server',
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          print('✅ [AUTH SERVICE] Registration successful in API');
          final data = responseData['data'];

          if (data != null && data is Map<String, dynamic>) {
            print('📦 [AUTH SERVICE] Data received: $data');
            final userData = data['user'];
            final token = data['token'];

            if (userData != null && token != null) {
              print('👤 [AUTH SERVICE] User data: $userData');
              print('🔑 [AUTH SERVICE] Token: $token');

              final combinedUserData = Map<String, dynamic>.from(userData);
              combinedUserData['token'] = token;

              print('🔗 [AUTH SERVICE] Combined user data: $combinedUserData');

              final user = User.fromJson(combinedUserData);
              print('✅ [AUTH SERVICE] User object created: ${user.toJson()}');

              return ApiResponse<User>(
                success: true,
                message: responseData['message'] ?? 'Registration successful',
                data: user,
                statusCode: response.statusCode,
              );
            } else {
              print('❌ [AUTH SERVICE] User data or token is null');
            }
          } else {
            print('❌ [AUTH SERVICE] Data is null or not a map');
          }
        } else {
          print('❌ [AUTH SERVICE] API returned success: false');
        }
      } else {
        print('❌ [AUTH SERVICE] HTTP Error: ${response.statusCode}');
      }

      return ApiResponse<User>(
        success: false,
        message: responseData['message'] ?? 'Registration failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ [AUTH SERVICE] Register error: $e');
      print('❌ [AUTH SERVICE] Error type: ${e.runtimeType}');
      return ApiResponse<User>(
        success: false,
        message: 'Registration failed: $e',
      );
    }
  }

  // Tambahkan juga method login di sini
  static Future<ApiResponse<User>> login(String email, String password) async {
    try {
      print('🔄 [AUTH SERVICE] Attempting login for: $email');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      print('📡 [AUTH SERVICE] Login Response Status: ${response.statusCode}');
      print('📡 [AUTH SERVICE] Login Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          if (data != null && data is Map<String, dynamic>) {
            final userData = data['user'];
            final token = data['token'];

            if (userData != null && token != null) {
              final combinedUserData = Map<String, dynamic>.from(userData);
              combinedUserData['token'] = token;

              final user = User.fromJson(combinedUserData);

              return ApiResponse<User>(
                success: true,
                message: responseData['message'] ?? 'Login successful',
                data: user,
                statusCode: response.statusCode,
              );
            }
          }
        }
      }

      return ApiResponse<User>(
        success: false,
        message: responseData['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ [AUTH SERVICE] Login error: $e');
      return ApiResponse<User>(success: false, message: 'Login failed: $e');
    }
  }

  static Future<ApiResponse<User>> loginPesertaMagang(
    String username,
    String password,
  ) async {
    try {
      print('🔄 [AUTH SERVICE] Attempting peserta magang login for: $username');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login-peserta-magang'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print(
        '📡 [AUTH SERVICE] Peserta Magang Login Response Status: ${response.statusCode}',
      );
      print(
        '📡 [AUTH SERVICE] Peserta Magang Login Response Body: ${response.body}',
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final data = responseData['data'];

          if (data != null && data is Map<String, dynamic>) {
            final userData = data['user'];
            final token = data['token'];

            if (userData != null && token != null) {
              final combinedUserData = Map<String, dynamic>.from(userData);
              combinedUserData['token'] = token;

              final user = User.fromJson(combinedUserData);

              return ApiResponse<User>(
                success: true,
                message: responseData['message'] ?? 'Login successful',
                data: user,
                statusCode: response.statusCode,
              );
            }
          }
        }
      }

      return ApiResponse<User>(
        success: false,
        message: responseData['message'] ?? 'Login peserta magang failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ [AUTH SERVICE] Peserta Magang Login error: $e');
      return ApiResponse<User>(
        success: false,
        message: 'Login peserta magang failed: $e',
      );
    }
  }
}
