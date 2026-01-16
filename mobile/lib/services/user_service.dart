import '../models/api_response.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<List<User>>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
  }) async {
    // Membuat query string manual atau biarkan Dio handling
    // Dio handling lebih bersih:
    // Tetapi endpoint user list biasanya via GET
    String query = '?page=$page&limit=$limit';
    if (role != null) query += '&role=$role';
    if (isActive != null) query += '&isActive=$isActive';

    return await _apiService.get(
      '/users$query',
      (data) => (data as List).map((item) => User.fromJson(item)).toList(),
    );
  }

  static Future<ApiResponse<User>> getUserById(String id) async {
    return await _apiService.get(
      '/users/$id',
      (data) => User.fromJson(data),
    );
  }

  static Future<ApiResponse<User>> createUser({
    required String username,
    required String password,
    String role = 'peserta_magang',
    bool isActive = true,
  }) async {
    return await _apiService.post(
      '/users',
      {
        'username': username,
        'password': password,
        'role': role,
        'isActive': isActive,
      },
      (data) => User.fromJson(data),
    );
  }

  static Future<ApiResponse<User>> updateUser({
    required String id,
    String? username,
    String? password,
    String? role,
    bool? isActive,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    if (isActive != null) data['isActive'] = isActive;
    if (avatar != null) data['avatar'] = avatar;

    return await _apiService.put(
      '/users/$id',
      data,
      (data) => User.fromJson(data),
    );
  }

  static Future<ApiResponse<void>> deleteUser(String id) async {
    return await _apiService.delete('/users/$id', null);
  }

  static Future<ApiResponse<User>> toggleUserStatus(String id) async {
    return await _apiService.patch(
      '/users/$id/toggle-status',
      {},
      (data) => User.fromJson(data),
    );
  }
}
