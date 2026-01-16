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
  bool _isCheckingAuth = true; // Default true agar start di Splash

  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;
  bool get isMentor => _user?.isPembimbing ?? false;

  AuthProvider() {
    // Sync immediately with AuthService static state
    if (AuthService.isLoggedIn) {
      _user = AuthService.currentUser;
      _token = AuthService.accessToken;
      _isCheckingAuth = false;
    } else {
      _isCheckingAuth = false; // No need to check if we trust AuthService
    }
  }

  // --- CORE LOGIC: LOAD DATA AMAN ---
  Future<void> _loadUserData() async {
    try {
      final userDataStr =
          await StorageService.getString(AppConstants.userDataKey);
      final token = await StorageService.getToken(); // Secure Storage

      print('🔍 [DEBUG] Loading User Data...');
      print('   -> Token found: ${token != null && token.isNotEmpty ? "YES (${token.substring(0, 5)}...)" : "NO"}');
      print('   -> UserData found: ${userDataStr != null ? "YES" : "NO"}');

      if (token != null && token.isNotEmpty) {
        _token = token;
      }

      if (userDataStr != null && userDataStr.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataStr);
          _user = User.fromJson(userData);
          print('✅ [DEBUG] User loaded successfully: ${_user?.username} (${_user?.role})');
        } catch (e) {
          print(
              '⚠️ Data user lokal korup, tapi Token AMAN. Aplikasi akan auto-repair. Error: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ [AUTH PROVIDER] Error loading storage: $e');
    }
  }

  // --- LOGIC CHECK AUTH (STAY LOGIN) ---
  Future<bool> checkAuthentication() async {
    print('🚀 [DEBUG] checkAuthentication started');
    _isCheckingAuth = true;
    notifyListeners();

    await _loadUserData();

    // 1. Cek Access Token Lokal
    if (_token != null && _token!.isNotEmpty) {
      // 2. Validate Session ke Server (Cek apakah Access Token Expired)
      final isValid = await _validateSession();
      if (isValid) {
        print('✅ [DEBUG] Session Valid (Access Token OK)');
        _isCheckingAuth = false;
        notifyListeners();
        return true;
      }

      // 3. Jika Expired, coba Rotate Token (Refresh Token)
      print('⚠️ [DEBUG] Access Token Expired/Invalid. Attempting Refresh...');
      final refreshed = await _attemptRefreshToken();
      if (refreshed) {
        print('✅ [DEBUG] Session Refreshed Successfully!');
        _isCheckingAuth = false;
        notifyListeners();
        return true;
      }
    } else {
       // Coba Refresh token jika access token hilang total (jarang terjadi tapi mungkin)
       final refreshed = await _attemptRefreshToken();
       if (refreshed) {
          _isCheckingAuth = false;
          notifyListeners();
          return true;
       }
    }

    print('❌ [DEBUG] All auth attempts failed. Logout.');
    // Jangan panggil logout full karena akan trigger notifyListeners berkali-kali
    // Cukup clear state internal jika perlu, atau biarkan logout yang bersihin.
    // Tapi karena AuthGate bergantung pada _user, pastikan _user null.
    _user = null; 
    _token = null; // Opsional: bersihkan memory
    // await logout(); // -> Hati-hati loop. Logout call notifyListeners.
    // Lebih aman kita set manual:
    
    _isCheckingAuth = false;
    _authHandled = false; // Reset guard
    notifyListeners();
    return false;
  }

  // Helper: Validasi sesi ke /auth/profile
  Future<bool> _validateSession() async {
    try {
      final response = await AuthService.getProfile();
      if (response.success) {
        // Update user data terbaru
        _user = response.data;
        await _saveUserData(_user!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    }
  }

  // Helper: Coba refresh access token menggunakan refresh token
  Future<bool> _attemptRefreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      // Call endpoint Refresh Token (Backend: /auth/refresh-token)
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/refresh-token'),
        headers: {
            'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['success'] == true) {
            // Backend returns: { token: accessToken, accessToken, expiresIn }
            final newAccessToken = data['data']['token'] ?? data['data']['accessToken'];
            if (newAccessToken != null) {
              await StorageService.setToken(newAccessToken);
              _token = newAccessToken;
              
              // Validate lagi user data
              await _validateSession(); 
              return true;
            }
         }
      }
    } catch (e) {
      print('❌ Refresh attempt error: $e');
    }
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
    String? avatar,
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
        avatar: avatar,
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
    await StorageService.removeTokens();
    await StorageService.remove(AppConstants.userDataKey);
    _user = null;
    _token = null;
    _authHandled = false;
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

  Future<List<dynamic>> fetchMentors(String bidang) async {
    try {
      final response = await AuthService.getPembimbingByBidang(bidang);
      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching mentors: $e');
    }
    return [];
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
    String? pembimbingId,
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
          pembimbingId: pembimbingId,
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

  bool _authHandled = false; // Guard to prevent double auth handling

  Future<void> _handleAuthSuccess(LoginResponse loginResponse) async {
    if (_authHandled) {
      print("⚠️ [AUTH] handleAuthSuccess called but already handled. Skipping.");
      return;
    }
    
    print("🔐 [AUTH] Handling Auth Success...");
    _authHandled = true;
    
    // 1. Simpan Access Token (Short-Lived)
    if (loginResponse.token != null) {
      print("   -> Saving Access Token: ${loginResponse.token.substring(0, 10)}...");
      await StorageService.setToken(loginResponse.token!);
      _token = loginResponse.token;
    } else {
      print("   ❌ [AUTH] Access Token is NULL in response!");
    }

    // 2. Simpan Refresh Token (Long-Lived)
    if (loginResponse.refreshToken != null) {
      print("   -> Saving Refresh Token: ${loginResponse.refreshToken!.substring(0, 10)}...");
      await StorageService.setRefreshToken(loginResponse.refreshToken!);
    } else {
      print("   ⚠️ [AUTH] Refresh Token is NULL in response!");
    }

    _user = loginResponse.user;
    await _saveUserData(_user!);
    _isLoading = false;
    print("✅ [AUTH] Auth Success Handled. User: ${_user?.username}");
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
