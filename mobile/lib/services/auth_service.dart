import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Login Admin/User
  static Future<ApiResponse<UserModel>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.login,
        {
          'username': username,
          'password': password,
        },
      );

      if (response['success']) {
        // Simpan token
        final token = response['data']['token'];
        await ApiService.saveToken(token);

        // Simpan user data
        final user = UserModel.fromJson(response['data']['user']);
        await ApiService.saveUserData(user.toJson());

        return ApiResponse<UserModel>(
          success: true,
          message: response['message'] ?? 'Login berhasil',
          data: user,
        );
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response['message'] ?? 'Login gagal',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Login gagal: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Login Peserta Magang
  static Future<ApiResponse<UserModel>> loginPesertaMagang(
    String username,
    String password,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.loginPesertaMagang,
        {
          'username': username,
          'password': password,
        },
      );

      if (response['success']) {
        // Simpan token
        final token = response['data']['token'];
        await ApiService.saveToken(token);

        // Simpan user data
        final user = UserModel.fromJson(response['data']['user']);
        await ApiService.saveUserData(user.toJson());

        return ApiResponse<UserModel>(
          success: true,
          message: response['message'] ?? 'Login berhasil',
          data: user,
        );
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response['message'] ?? 'Login gagal',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Login gagal: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Register
  static Future<ApiResponse<UserModel>> register(
    String nama,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await ApiService.post(
        ApiConfig.register,
        {
          'nama': nama,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response['success']) {
        // Simpan token jika registrasi langsung login
        if (response['data']['token'] != null) {
          final token = response['data']['token'];
          await ApiService.saveToken(token);

          // Simpan user data
          final user = UserModel.fromJson(response['data']['user']);
          await ApiService.saveUserData(user.toJson());

          return ApiResponse<UserModel>(
            success: true,
            message: response['message'] ?? 'Registrasi berhasil',
            data: user,
          );
        }

        return ApiResponse<UserModel>(
          success: true,
          message: response['message'] ?? 'Registrasi berhasil',
        );
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response['message'] ?? 'Registrasi gagal',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Registrasi gagal: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Logout
  static Future<ApiResponse<void>> logout() async {
    try {
      // Hapus token dan user data dari local storage
      await ApiService.clearAllData();

      // Optional: call backend logout endpoint jika ada
      // await ApiService.post(ApiConfig.logout, {});

      return ApiResponse<void>(
        success: true,
        message: 'Logout berhasil',
      );
    } catch (e) {
      // Tetap hapus data lokal meskipun API gagal
      await ApiService.clearAllData();
      
      return ApiResponse<void>(
        success: true,
        message: 'Logout berhasil',
      );
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await ApiService.isLoggedIn();
  }

  // Get current user
  static Future<UserModel?> getCurrentUser() async {
    final userData = await ApiService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Refresh token (jika backend support)
  static Future<ApiResponse<String>> refreshToken() async {
    try {
      final response = await ApiService.post(ApiConfig.refreshToken, {});

      if (response['success']) {
        final newToken = response['data']['token'];
        await ApiService.saveToken(newToken);

        return ApiResponse<String>(
          success: true,
          message: 'Token berhasil diperbarui',
          data: newToken,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: response['message'] ?? 'Gagal memperbarui token',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Gagal memperbarui token: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
}

