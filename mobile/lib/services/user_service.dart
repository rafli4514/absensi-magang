import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  // Get profile
  static Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await ApiService.get(ApiConfig.profile);

      if (response['success']) {
        final user = UserModel.fromJson(response['data']);
        
        // Update local storage
        await ApiService.saveUserData(user.toJson());
        
        return ApiResponse<UserModel>(
          success: true,
          message: response['message'],
          data: user,
        );
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil data profil',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Gagal mengambil data profil: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Update profile
  static Future<ApiResponse<UserModel>> updateProfile({
    String? nama,
    String? email,
    String? id_instansi,
    String? jabatan,
    String? divisi,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nama != null) body['nama'] = nama;
      if (email != null) body['email'] = email;
      if (id_instansi != null) body['id_instansi'] = id_instansi;
      if (jabatan != null) body['jabatan'] = jabatan;
      if (divisi != null) body['divisi'] = divisi;

      final response = await ApiService.put(ApiConfig.updateProfile, body);

      if (response['success']) {
        final user = UserModel.fromJson(response['data']);
        
        // Update local storage
        await ApiService.saveUserData(user.toJson());
        
        return ApiResponse<UserModel>(
          success: true,
          message: response['message'] ?? 'Profil berhasil diperbarui',
          data: user,
        );
      } else {
        return ApiResponse<UserModel>(
          success: false,
          message: response['message'] ?? 'Gagal memperbarui profil',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Gagal memperbarui profil: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Change password
  static Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConfig.changePassword,
        {
          'currentPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      if (response['success']) {
        return ApiResponse<void>(
          success: true,
          message: response['message'] ?? 'Password berhasil diubah',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response['message'] ?? 'Gagal mengubah password',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Gagal mengubah password: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Upload avatar
  static Future<ApiResponse<String>> uploadAvatar(String filePath) async {
    try {
      final response = await ApiService.uploadFile(
        ApiConfig.uploadAvatar,
        filePath,
        'avatar',
      );

      if (response['success']) {
        final avatarUrl = response['data']['avatarUrl'] ?? response['data']['avatar'];
        
        // Update user data in local storage
        final userData = await ApiService.getUserData();
        if (userData != null) {
          userData['avatar'] = avatarUrl;
          await ApiService.saveUserData(userData);
        }
        
        return ApiResponse<String>(
          success: true,
          message: response['message'] ?? 'Avatar berhasil diupload',
          data: avatarUrl,
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: response['message'] ?? 'Gagal mengupload avatar',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Gagal mengupload avatar: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Delete avatar
  static Future<ApiResponse<void>> deleteAvatar() async {
    try {
      final response = await ApiService.delete(ApiConfig.uploadAvatar);

      if (response['success']) {
        // Update user data in local storage
        final userData = await ApiService.getUserData();
        if (userData != null) {
          userData['avatar'] = null;
          await ApiService.saveUserData(userData);
        }
        
        return ApiResponse<void>(
          success: true,
          message: response['message'] ?? 'Avatar berhasil dihapus',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: response['message'] ?? 'Gagal menghapus avatar',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Gagal menghapus avatar: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
}

