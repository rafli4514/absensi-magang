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

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataStr = await StorageService.getString(AppConstants.userDataKey);
      final token = await StorageService.getString(AppConstants.tokenKey);
      
      if (userDataStr != null && token != null) {
        final userData = jsonDecode(userDataStr);
        _user = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> checkAuthentication() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      return false;
    }

    // Optionally verify token dengan getProfile
    try {
      final profileResponse = await AuthService.getProfile();
      if (profileResponse.success && profileResponse.data != null) {
        _user = profileResponse.data;
        await _saveUserData(_user!);
        return true;
      } else {
        // Token invalid, clear storage
        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(username, password);
      
      if (response.success && response.data != null) {
        final loginResponse = response.data!;
        
        // Simpan token
        await StorageService.setString(
          AppConstants.tokenKey, 
          loginResponse.token
        );
        
        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        
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
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
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
          loginResponse.token
        );
        
        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        
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
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password, {String? role}) async {
    // Register hanya butuh username dan password sesuai backend
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(username, password, role: role);
      
      if (response.success && response.data != null) {
        final loginResponse = response.data!;
        
        // Simpan token
        await StorageService.setString(
          AppConstants.tokenKey, 
          loginResponse.token
        );
        
        // Simpan user data
        _user = loginResponse.user;
        await _saveUserData(_user!);
        
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
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userDataKey);
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
      print('Error refreshing profile: $e');
    }
  }
}