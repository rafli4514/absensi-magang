import 'dart:convert';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final ApiService _apiService = ApiService();

  // State Management Sederhana (Static)
  static User? currentUser;
  static String? accessToken;
  static bool _initialized = false;

  /// Init Auth State saat App Start (Panggil di main.dart)
  static Future<void> init() async {
    if (_initialized) return;
    print("🔐 AuthService: Initializing...");

    try {
      // 1. Load Token
      accessToken = await StorageService.getToken();
      
      // 2. Load User Data
      final userJson = await StorageService.getString(AppConstants.userDataKey);
      if (accessToken != null && accessToken!.isNotEmpty && userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        currentUser = User.fromJson(data);
        print("✅ AuthService: User loaded -> ${currentUser?.username}");
      } else {
        print("ℹ️ AuthService: No active session found.");
      }
    } catch (e) {
      print("❌ AuthService Init Error: $e");
    } finally {
      _initialized = true;
    }
  }

  /// Cek status login (Synchronous / Instant)
  static bool get isLoggedIn => 
      accessToken != null && accessToken!.isNotEmpty && currentUser != null;


  static Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
  ) async {
    // Endpoint bisa berbeda antara user biasa dan peserta,
    // sesuaikan jika backend membedakan route
    return await _apiService.post(
      AppConstants.loginEndpoint,
      {'username': username, 'password': password},
      (data) => LoginResponse.fromJson(data),
    );
  }

  // Fetch Mentors by Bidang
  static Future<ApiResponse<List<dynamic>>> getPembimbingByBidang(String bidang) async {
    return await _apiService.get(
      '${AppConstants.pembimbingEndpoint}?bidang=$bidang',
      (data) {
        if (data is List) return data;
        return [];
      },
    );
  }

  // Unified Register Method
  static Future<ApiResponse<LoginResponse>> registerPesertaMagang({
    required String nama,
    required String username,
    required String password,
    String? idPesertaMagang,
    required String divisi,
    required String nomorHp,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? namaMentor,
    String? pembimbingId,
    String? instansi,
    String? idInstansi,
    String? status,
  }) async {
    final data = {
      'nama': nama,
      'username': username,
      'password': password,
      'divisi': divisi,
      'nomorHp': nomorHp,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      if (idPesertaMagang != null) 'id_peserta_magang': idPesertaMagang,
      if (instansi != null) 'instansi': instansi,
      if (idInstansi != null) 'id_instansi': idInstansi,
      if (status != null) 'status': status,
      if (namaMentor != null) 'namaMentor': namaMentor,
      if (pembimbingId != null) 'pembimbingId': pembimbingId,
    };

    return await _apiService.post(
      AppConstants.registerPesertaMagangEndpoint,
      data,
      (data) {
        // Logic mapping user + pesertaMagang (sama seperti sebelumnya)
        final userMap = <String, dynamic>{
          ...(data['user'] ?? {}),
          if (data['pesertaMagang'] != null) ...{
            'nama': data['pesertaMagang']['nama'],
            'idPesertaMagang': data['pesertaMagang']['id_peserta_magang'],
            'divisi': data['pesertaMagang']['divisi'],
            'instansi': data['pesertaMagang']['instansi'],
            'nomorHp': data['pesertaMagang']['nomorHp'],
            'tanggalMulai': data['pesertaMagang']['tanggalMulai'],
            'tanggalSelesai': data['pesertaMagang']['tanggalSelesai'],
            'avatar': data['pesertaMagang']['avatar'],
            'namaMentor': data['pesertaMagang']['namaMentor'],
            'pembimbingId': data['pesertaMagang']['pembimbingId'],
          },
          if (!(data['user'] ?? {}).containsKey('role'))
            'role': 'PESERTA_MAGANG',
        };
        return LoginResponse(
          user: User.fromJson(userMap),
          token: data['token'] ?? '',
          expiresIn: data['expiresIn'] ?? '24h',
        );
      },
    );
  }

  static Future<ApiResponse<LoginResponse>> register({
    required String username,
    required String password,
    String? nama,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? role = "USER",
  }) async {
    final data = {
      'username': username,
      'password': password,
      'role': role?.toUpperCase() ?? 'USER',
      if (nama != null) 'nama': nama,
      if (divisi != null) 'divisi': divisi,
      if (instansi != null) 'instansi': instansi,
      if (nomorHp != null) 'nomorHp': nomorHp,
      if (tanggalMulai != null) 'tanggalMulai': tanggalMulai,
      if (tanggalSelesai != null) 'tanggalSelesai': tanggalSelesai,
    };

    return await _apiService.post(
      AppConstants.registerEndpoint,
      data,
      (data) => LoginResponse.fromJson(data),
    );
  }

  static Future<ApiResponse<User>> getProfile() async {
    return await _apiService.get(
      AppConstants.profileEndpoint,
      (data) => User.fromJson(data),
    );
  }

  static Future<ApiResponse<User>> updateProfile({
    String? username,
    String? nama,
    String? idPesertaMagang,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? currentPassword,
    String? newPassword,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? namaMentor,
    String? avatar,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (nama != null) body['nama'] = nama;
    if (idPesertaMagang != null) body['id_peserta_magang'] = idPesertaMagang;
    if (divisi != null) body['divisi'] = divisi;
    if (instansi != null) body['instansi'] = instansi;
    if (nomorHp != null) body['nomorHp'] = nomorHp;
    if (namaMentor != null) body['namaMentor'] = namaMentor;
    if (tanggalMulai != null) body['tanggalMulai'] = tanggalMulai;
    if (tanggalSelesai != null) body['tanggalSelesai'] = tanggalSelesai;
    if (avatar != null) body['avatar'] = avatar;

    if (newPassword != null) {
      body['newPassword'] = newPassword;
      if (currentPassword != null) body['currentPassword'] = currentPassword;
    }

    return await _apiService.put(
      AppConstants.profileEndpoint,
      body,
      (data) => User.fromJson(data),
    );
  }

  static Future<void> logout() async {
    await StorageService.removeTokens();
    await StorageService.remove(AppConstants.userDataKey);
  }
}
