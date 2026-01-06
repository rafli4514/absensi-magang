import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  bool get isMentor => _user?.isPembimbing ?? false;

  AuthProvider() {
    _loadUserData();
  }

  // --- CORE LOGIC: LOAD DATA AMAN ---
  Future<void> _loadUserData() async {
    try {
      final userDataStr =
          await StorageService.getString(AppConstants.userDataKey);
      final token = await StorageService.getString(AppConstants.tokenKey);

      // [PERBAIKAN MUTLAK DISINI]
      // Simpan token DULUAN. Jangan peduli data user rusak atau tidak.
      // Selama ada string token di HP, kita anggap dia login.
      if (token != null && token.isNotEmpty) {
        _token = token;
      }

      // Baru coba parsing data user
      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataStr);
          _user = User.fromJson(userData);
        } catch (e) {
          print(
              '⚠️ Data user lokal korup, tapi Token AMAN. Aplikasi akan auto-repair.');
          // Jangan lakukan apa-apa di sini. Biarkan _user null.
          // Nanti checkAuthentication() yang akan sadar _token ada tapi _user null,
          // lalu dia akan fetch data baru.
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error loading storage: $e');
    }
  }

  // --- LOGIC CHECK AUTH (STAY LOGIN) ---
  Future<bool> checkAuthentication() async {
    // 1. Load data dari HP
    await _loadUserData();

    // 2. Cek apakah Token ada?
    if (_token == null || _token!.isEmpty) {
      return false; // Tidak ada token, harus login
    }

    // 3. Skenario A: Data User Lengkap (Ideal)
    if (_user != null) {
      // Sync data terbaru di background agar tidak memblokir UI
      refreshProfile().catchError((e) {
        if (kDebugMode) print('Background sync failed (Offline?): $e');
      });
      return true; // IZINKAN MASUK
    }

    // 4. Skenario B: Token Ada, tapi Data User Hilang/Rusak
    // Coba pulihkan session dengan meminta data baru ke server
    print("⚠️ Memulihkan sesi menggunakan Token...");
    try {
      await refreshProfile(); // Tunggu sampai selesai

      if (_user != null) {
        print("✅ Sesi berhasil dipulihkan!");
        return true; // IZINKAN MASUK
      }
    } catch (e) {
      print("❌ Gagal memulihkan sesi: $e");
    }

    // 5. Jika semua gagal, baru return false
    return false;
  }

  // --- REFRESH PROFILE ---
  Future<void> refreshProfile() async {
    try {
      // Ambil data profile terbaru
      final response = await AuthService.getProfile();
      if (response.success && response.data != null) {
        _user = response.data;

        // Simpan data mentah agar struktur lengkap (termasuk relasi) terjaga di storage
        try {
          if (_token != null) {
            final headers = {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            };

            final httpResponse = await http
                .get(
                  Uri.parse('${AppConstants.baseUrl}/auth/profile'),
                  headers: headers,
                )
                .timeout(const Duration(seconds: 10));

            if (httpResponse.statusCode == 200) {
              final rawData = jsonDecode(httpResponse.body);
              if (rawData['success'] == true && rawData['data'] != null) {
                await StorageService.setString(
                  AppConstants.userDataKey,
                  jsonEncode(rawData['data']),
                );
              }
            }
          }
        } catch (e) {
          // Fallback save jika raw fetch gagal
          await _saveUserData(_user!);
        }

        notifyListeners();
      } else if (response.statusCode == 401) {
        // Hanya logout jika server menolak token (Token Expired/Invalid)
        print("🔒 Token expired, logging out...");
        await logout();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error refreshing profile: $e');
    }
  }

  // --- UPDATE PROFILE ---
  Future<bool> updateUserProfile({
    String? username,
    String? nama,
    String? idPesertaMagang,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? namaMentor,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.updateProfile(
        username: username,
        nama: nama,
        idPesertaMagang: idPesertaMagang,
        divisi: divisi,
        instansi: instansi,
        nomorHp: nomorHp,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        namaMentor: namaMentor,
      );

      if (response.success) {
        await refreshProfile(); // Refresh agar UI update
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Profile update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- CHANGE PASSWORD ---
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.updateProfile(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengubah password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userDataKey);
    _user = null;
    _token = null;
    notifyListeners();
  }

  // --- AUTH METHODS (LOGIN/REGISTER) ---

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await AuthService.login(username, password);
      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String username,
    String password, {
    String? nama,
    String? idPesertaMagang,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? role,
    String? namaMentor,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ApiResponse<LoginResponse> response;
      if (nama != null &&
          nama.isNotEmpty &&
          divisi != null &&
          divisi.isNotEmpty &&
          nomorHp != null &&
          nomorHp.isNotEmpty &&
          tanggalMulai != null &&
          tanggalMulai.isNotEmpty &&
          tanggalSelesai != null &&
          tanggalSelesai.isNotEmpty) {
        response = await AuthService.registerPesertaMagang(
          nama: nama,
          username: username,
          password: password,
          idPesertaMagang: idPesertaMagang,
          divisi: divisi,
          nomorHp: nomorHp,
          tanggalMulai: tanggalMulai,
          tanggalSelesai: tanggalSelesai,
          instansi: instansi,
          namaMentor: namaMentor,
        );
      } else {
        response = await AuthService.register(
          username: username,
          password: password,
          nama: nama,
          divisi: divisi,
          instansi: instansi,
          nomorHp: nomorHp,
          tanggalMulai: tanggalMulai,
          tanggalSelesai: tanggalSelesai,
          role: role,
        );
      }
      if (response.success && response.data != null) {
        await _handleAuthSuccess(response.data!);
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _handleAuthSuccess(LoginResponse loginResponse) async {
    await StorageService.setString(AppConstants.tokenKey, loginResponse.token);
    _user = loginResponse.user;
    await _saveUserData(_user!);
    _token = loginResponse.token;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserData(User user) async {
    await StorageService.setString(
      AppConstants.userDataKey,
      jsonEncode(user.toJson()),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
