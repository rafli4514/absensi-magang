// lib/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

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
      final userDataStr = await StorageService.getString(
        AppConstants.userDataKey,
      );
      final token = await StorageService.getString(AppConstants.tokenKey);

      if (userDataStr != null && token != null) {
        final userData = jsonDecode(userDataStr);
        _user = User.fromJson(userData);
        _token = token;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error loading user data: $e');
    }
  }

  // --- ACTIONS ---

  // 1. Refresh Profile (Ambil data terbaru dari server)
  Future<void> refreshProfile() async {
    try {
      final response = await AuthService.getProfile();
      if (response.success && response.data != null) {
        _user = response.data;
        await _saveUserData(_user!); // Simpan data terbaru ke storage
        notifyListeners(); // Update UI
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error refreshing profile: $e');
    }
  }

  // 2. Update Profile + Auto Sync
  Future<bool> updateUserProfile({
    String? username,
    String? nama,
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
        _error = response.message ?? 'Profile update failed';
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
      // Menggunakan endpoint updateProfile yang sudah mendukung parameter password
      final response = await AuthService.updateProfile(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Gagal mengubah password';
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
      // Jika semua field required tersedia, gunakan endpoint register peserta magang baru
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

  Future<void> _handleAuthSuccess(dynamic loginResponse) async {
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

  Future<bool> checkAuthentication() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      await refreshProfile(); // Validasi token & update data user
      return _user != null;
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
