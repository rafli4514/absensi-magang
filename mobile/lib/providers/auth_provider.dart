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

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataStr =
          await StorageService.getString(AppConstants.userDataKey);
      final token = await StorageService.getString(AppConstants.tokenKey);

      // Pastikan string tidak kosong sebelum decode
      if (userDataStr != null &&
          userDataStr.isNotEmpty &&
          token != null &&
          token.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataStr);
          _user = User.fromJson(userData);
          _token = token;
          notifyListeners();
        } catch (e) {
          // Jika JSON error (misal format berubah), hapus data corrupt agar user login ulang
          print('Data corrupt, clearing storage...');
          await logout();
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error loading user data: $e');
    }
  }

  // --- ACTIONS ---

  // Perbaikan Logika Check Authentication
  Future<bool> checkAuthentication() async {
    // 1. Wajib tunggu load data dari HP selesai dulu
    await _loadUserData();

    // 2. Cek apakah di HP ada Token & Data User
    if (_token != null && _user != null) {
      // 3. Coba sync data terbaru ke server di background (Silent Sync)
      // Kita tidak await ini agar app cepat masuk ke Home
      // dan jika offline, user tetap bisa masuk.
      refreshProfile().catchError((e) {
        if (kDebugMode) print('Offline mode or sync failed: $e');
      });

      return true; // Izinkan masuk karena ada data di local
    }

    return false; // Tidak ada data login
  }

  // 1. Refresh Profile (Ambil data terbaru dari server)
  Future<void> refreshProfile() async {
    try {
      // Get raw data from API to preserve pesertaMagang structure
      final response = await AuthService.getProfile();
      if (response.success && response.data != null) {
        _user = response.data;
        
        // Also fetch raw data to preserve pesertaMagang in storage
        try {
          final token = await StorageService.getString(AppConstants.tokenKey);
          if (token != null) {
            final headers = {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            };
            
            final httpResponse = await http.get(
              Uri.parse('${AppConstants.baseUrl}/auth/profile'),
              headers: headers,
            ).timeout(const Duration(seconds: 10));
            
            if (httpResponse.statusCode == 200) {
              final rawData = jsonDecode(httpResponse.body);
              if (rawData['success'] == true && rawData['data'] != null) {
                // Save raw data (including pesertaMagang) to storage
                await StorageService.setString(
                  AppConstants.userDataKey,
                  jsonEncode(rawData['data']),
                );
              }
            }
          }
        } catch (e) {
          // Fallback to saving User.toJson() if raw fetch fails
          if (kDebugMode) print('⚠️ Could not save raw profile data: $e');
          await _saveUserData(_user!);
        }
        
        notifyListeners(); // Update UI
      } else if (response.statusCode == 401) {
        // Jika token expired (401), baru kita logout paksa
        await logout();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error refreshing profile: $e');
    }
  }

  // 2. Update Profile + Auto Sync
  Future<bool> updateUserProfile({
    String? username,
    String? nama,
    String? idPesertaMagang, // NISN/NIM
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
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
      );

      if (response.success) {
        // PENTING: Ambil data profile terbaru agar UI sinkron
        await refreshProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // FIX: response.message tidak null, jadi ?? redundant
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

  // 3. Change Password
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
        // FIX: response.message tidak null, jadi ?? redundant
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

  Future<void> logout() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userDataKey);
    _user = null;
    _token = null;
    notifyListeners();
  }

  // --- AUTH METHODS (Login/Register standard) ---

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
