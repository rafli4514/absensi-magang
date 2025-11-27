import '../../models/user.dart';
import '../../models/login_response.dart';
import '../../models/api_response.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class AuthService {
  // Login untuk admin/staff (menggunakan username)
  static Future<ApiResponse<LoginResponse>> login(
    String username, 
    String password
  ) async {
    final response = await ApiService().post(
      AppConstants.loginEndpoint,
      {
        'username': username, 
        'password': password,
      },
      (data) => LoginResponse.fromJson(data), 
    );
    return response;
  }

  // Login untuk peserta magang
  static Future<ApiResponse<LoginResponse>> loginPesertaMagang(
    String username, 
    String password
  ) async {
    final response = await ApiService().post(
      AppConstants.loginPesertaEndpoint,
      {
        'username': username,
        'password': password,
      },
      (data) => LoginResponse.fromJson(data),
    );
    return response;
  }

  // Register (sesuai dengan backend yang pakai username)
  static Future<ApiResponse<LoginResponse>> register(
    String username,
    String password, 
    {String? role}
  ) async {
    final response = await ApiService().post(
      AppConstants.registerEndpoint,
      {
        'username': username,
        'password': password,
        if (role != null) 'role': role,
      },
      (data) => LoginResponse.fromJson(data),
    );
    return response;
  }

  // Get profile (protected route)
  static Future<ApiResponse<User>> getProfile() async {
    final response = await ApiService().get(
      AppConstants.profileEndpoint,
      (data) => User.fromJson(data),
    );
    return response;
  }

  // Update profile (protected route)
  static Future<ApiResponse<User>> updateProfile({
    String? username,
    String? currentPassword,
    String? newPassword,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (newPassword != null) {
      body['newPassword'] = newPassword;
      if (currentPassword != null) {
        body['currentPassword'] = currentPassword;
      }
    }

    final response = await ApiService().put(
      AppConstants.profileEndpoint,
      body,
      (data) => User.fromJson(data),
    );
    return response;
  }

  // Refresh token
  static Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final response = await ApiService().post(
      AppConstants.refreshTokenEndpoint,
      {},
      (data) => data as Map<String, dynamic>,
    );
    return response;
  }

  // Logout (hanya hapus token di local)
  static Future<void> logout() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userDataKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
