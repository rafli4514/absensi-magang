// auth_service.dart
import '../../models/api_response.dart';
import '../../models/login_response.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class AuthService {
  static final ApiService _apiService = ApiService();

  // Login untuk admin/staff (menggunakan username)
  static Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
  ) async {
    print('鳩 [AUTH SERVICE] Attempting login with username: $username');

    final response = await _apiService.post(AppConstants.loginEndpoint, {
      'username': username,
      'password': password,
    }, (data) => LoginResponse.fromJson(data));

    print(
      '鳩 [AUTH SERVICE] Login response: ${response.success} - ${response.message}',
    );
    return response;
  }

  // Login untuk peserta magang
  static Future<ApiResponse<LoginResponse>> loginPesertaMagang(
    String username,
    String password,
  ) async {
    print(
      '鳩 [AUTH SERVICE] Attempting peserta login with username: $username',
    );

    final response = await _apiService.post(AppConstants.loginPesertaEndpoint, {
      'username': username,
      'password': password,
    }, (data) => LoginResponse.fromJson(data));

    print(
      '鳩 [AUTH SERVICE] Peserta login response: ${response.success} - ${response.message}',
    );
    return response;
  }

  // Register dengan semua field untuk peserta magang
  static Future<ApiResponse<LoginResponse>> register({
    required String username,
    required String password,
    String? nama,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? role = "user", // Default sesuai backend
  }) async {
    print('鳩 [AUTH SERVICE] Attempting register with username: $username');

    // Prepare data sesuai dengan yang diharapkan backend
    final data = {
      'username': username,
      'password': password,
      'role': role?.toUpperCase() ?? 'USER', // Backend expects uppercase
      if (nama != null && nama.isNotEmpty) 'nama': nama,
      if (divisi != null && divisi.isNotEmpty) 'divisi': divisi,
      if (instansi != null && instansi.isNotEmpty) 'instansi': instansi,
      if (nomorHp != null && nomorHp.isNotEmpty) 'nomorHp': nomorHp,
      if (tanggalMulai != null && tanggalMulai.isNotEmpty)
        'tanggalMulai': tanggalMulai,
      if (tanggalSelesai != null && tanggalSelesai.isNotEmpty)
        'tanggalSelesai': tanggalSelesai,
    };

    print('[AUTH SERVICE] Registration data: $data');

    final response = await _apiService.post(
      AppConstants.registerEndpoint,
      data,
      (data) => LoginResponse.fromJson(data),
    );

    print(
      '鳩 [AUTH SERVICE] Register response: ${response.success} - ${response.message}',
    );
    return response;
  }

  // Get profile (protected route)
  static Future<ApiResponse<User>> getProfile() async {
    final response = await _apiService.get(
      AppConstants.profileEndpoint,
      (data) => User.fromJson(data),
    );
    return response;
  }

  // Update profile (protected route) - PERBAIKAN DI SINI
  static Future<ApiResponse<User>> updateProfile({
    String? username,
    String? nama,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? currentPassword,
    String? newPassword,
    // Menambahkan parameter tanggal agar AuthProvider tidak error
    String? tanggalMulai,
    String? tanggalSelesai,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (nama != null) body['nama'] = nama;
    if (divisi != null) body['divisi'] = divisi;
    if (instansi != null) body['instansi'] = instansi;
    if (nomorHp != null) body['nomorHp'] = nomorHp;

    // Menambahkan logic untuk mengirim tanggal ke backend
    if (tanggalMulai != null) body['tanggalMulai'] = tanggalMulai;
    if (tanggalSelesai != null) body['tanggalSelesai'] = tanggalSelesai;

    // Password change logic sesuai backend
    if (newPassword != null) {
      body['newPassword'] = newPassword;
      if (currentPassword != null) {
        body['currentPassword'] = currentPassword;
      }
    }

    final response = await _apiService.put(
      AppConstants.profileEndpoint,
      body,
      (data) => User.fromJson(data),
    );
    return response;
  }

  // Upload avatar
  static Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      final response = await _apiService.multipartPost(
        '${AppConstants.profileEndpoint}/upload-avatar',
        {}, // additional fields if needed
        imageBytes,
        fileName,
        'avatar',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      return response;
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to upload avatar: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  // Remove avatar
  static Future<ApiResponse<User>> removeAvatar() async {
    final response = await _apiService.delete(
      '${AppConstants.profileEndpoint}/avatar',
      (data) => User.fromJson(data),
    );
    return response;
  }

  // Refresh token
  static Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final response = await _apiService.post(
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
