import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = StorageService.getString(AppConstants.userDataKey);
    if (userData != null) {
      // Parse user data from storage
      // _user = User.fromJson(jsonDecode(userData));
    }
  }

  Future<bool> checkAuthentication() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    return token != null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 2));
      
      // Create mock user for demo
      _user = User(
        id: '1',
        name: 'John Doe',
        email: email,
        department: 'IT',
        position: 'Developer',
        token: 'mock_token',
      );
      
      await StorageService.setString(AppConstants.tokenKey, 'mock_token');
      _isLoading = false;
      notifyListeners();
      return true;
      
      // Uncomment when you have real API
      /*
      final response = await AuthService.login(email, password);
      
      if (response.success) {
        _user = response.data;
        await StorageService.setString(AppConstants.tokenKey, response.data!.token!);
        await StorageService.setString(AppConstants.userDataKey, response.data!.toJson().toString());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String department) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, simulate successful registration
      await Future.delayed(const Duration(seconds: 2));
      
      // Create mock user for demo
      _user = User(
        id: '1',
        name: name,
        email: email,
        department: department,
        position: 'Employee',
        token: 'mock_token',
      );
      
      await StorageService.setString(AppConstants.tokenKey, 'mock_token');
      _isLoading = false;
      notifyListeners();
      return true;
      
      // Uncomment when you have real API
      /*
      final response = await AuthService.register(name, email, password, department);
      
      if (response.success) {
        _user = response.data;
        await StorageService.setString(AppConstants.tokenKey, response.data!.token!);
        await StorageService.setString(AppConstants.userDataKey, response.data!.toJson().toString());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */
    } catch (e) {
      _error = e.toString();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}