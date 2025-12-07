// auth_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

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
      print('❌ [AUTH PROVIDER] Error loading user data: $e');
    }
  }

  Future<bool> checkAuthentication() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      return false;
    }

    // Verify token dengan getProfile sesuai backend logic
    try {
      final profileResponse = await AuthService.getProfile();
      if (profileResponse.success && profileResponse.data != null) {
        _user = profileResponse.data;
        await _saveUserData(_user!);
        _token = token;
        notifyListeners();
        return true;
      } else {
        // Token invalid, clear storage
        await logout();
        return false;
      }
    } catch (e) {
      print('❌ [AUTH PROVIDER] Error checking authentication: $e');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔵 [AUTH PROVIDER] Starting login...');
    print('👤 [AUTH PROVIDER] Username: $username');

    try {
      final response = await AuthService.login(username, password);

      print('🔵 [AUTH PROVIDER] Login API response received');
      print('🔵 [AUTH PROVIDER] Success: ${response.success}');
      print('🔵 [AUTH PROVIDER] Message: ${response.message}');
      print('🔵 [AUTH PROVIDER] Status Code: ${response.statusCode}');

      if (response.success && response.data != null) {
        final loginResponse = response.data!;

        print(
          '🔵 [AUTH PROVIDER] Login successful, saving token and user data',
        );

        // Simpan token
        await StorageService.setString(
          AppConstants.tokenKey,
          loginResponse.token,
        );

        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        _token = loginResponse.token;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();

        print('❌ [AUTH PROVIDER] Login failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      print('❌ [AUTH PROVIDER] Login error: $_error');
      return false;
    }
  }

  Future<bool> loginPesertaMagang(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.loginPesertaMagang(username, password);

      if (response.success && response.data != null) {
        final loginResponse = response.data!;

        // Simpan token
        await StorageService.setString(
          AppConstants.tokenKey,
          loginResponse.token,
        );

        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        _token = loginResponse.token;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
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
    String? role = "user", // Default sesuai backend
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
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

      if (response.success && response.data != null) {
        final loginResponse = response.data!;

        // Simpan token
        await StorageService.setString(
          AppConstants.tokenKey,
          loginResponse.token,
        );

        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        _token = loginResponse.token;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearStorage();

      _user = null;
      _token = null;
      _error = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearStorage() async {
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userDataKey);
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

  // Refresh user profile
  Future<void> refreshProfile() async {
    try {
      final response = await AuthService.getProfile();
      if (response.success && response.data != null) {
        _user = response.data;
        await _saveUserData(_user!);
        notifyListeners();
      }
    } catch (e) {
      print('❌ [AUTH PROVIDER] Error refreshing profile: $e');
    }
  }

  Future<bool> updateUserProfile({
    String? username,
    String? nama,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? currentPassword,
    String? newPassword,
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
        currentPassword: currentPassword,
        newPassword: newPassword,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        await _saveUserData(_user!);
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

  // Refresh token
  Future<bool> refreshAuthToken() async {
    try {
      final response = await AuthService.refreshToken();
      if (response.success && response.data != null) {
        final newToken = response.data!['token'];
        if (newToken != null) {
          await StorageService.setString(AppConstants.tokenKey, newToken);
          _token = newToken;
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ [AUTH PROVIDER] Error refreshing token: $e');
      return false;
    }
  }
}
