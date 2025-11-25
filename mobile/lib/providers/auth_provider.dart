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
  String? get token => _token;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = StorageService.getString(AppConstants.tokenKey);
      final userData = StorageService.getString(AppConstants.userDataKey);

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      await _clearStorage();
    }
  }

  Future<bool> checkAuthentication() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔵 [AUTH PROVIDER] Starting registration...');
    print('📧 [AUTH PROVIDER] Email: $email');

    try {
      final response = await AuthService.register(email, password);

      print('🔄 [AUTH PROVIDER] AuthService response received');
      print('✅ [AUTH PROVIDER] Response success: ${response.success}');
      print('📝 [AUTH PROVIDER] Response message: ${response.message}');
      print('🔢 [AUTH PROVIDER] Response statusCode: ${response.statusCode}');
      print('👤 [AUTH PROVIDER] Response data: ${response.data}');

      if (response.success && response.data != null) {
        print('✅ [AUTH PROVIDER] Registration successful!');
        _user = response.data!;
        _token = response.data!.token;

        print('🔑 [AUTH PROVIDER] Token: $_token');
        print('👤 [AUTH PROVIDER] User: ${_user!.toJson()}');

        await StorageService.setString(AppConstants.tokenKey, _token!);
        await StorageService.setString(
          AppConstants.userDataKey,
          jsonEncode(_user!.toJson()),
        );

        print('💾 [AUTH PROVIDER] Data saved to storage');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        print('❌ [AUTH PROVIDER] Registration failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      print('❌ [AUTH PROVIDER] Registration error: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);

      if (response.success && response.data != null) {
        _user = response.data!;
        _token = response.data!.token;

        await StorageService.setString(AppConstants.tokenKey, _token!);
        await StorageService.setString(
          AppConstants.userDataKey,
          jsonEncode(_user!.toJson()),
        );

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
      _error = 'Login failed: $e';
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
        _user = response.data!;
        _token = response.data!.token;

        await StorageService.setString(AppConstants.tokenKey, _token!);
        await StorageService.setString(
          AppConstants.userDataKey,
          jsonEncode(_user!.toJson()),
        );

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
      _error = 'Login failed: $e';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
