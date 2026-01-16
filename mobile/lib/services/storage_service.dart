import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage();

  // Getter ini menjamin _prefs selalu di-load sebelum dipakai
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- SECURE STORAGE (Tokens) ---
  static Future<void> setToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  static Future<void> removeTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: 'refresh_token');
  }

  // --- SHARED PREFERENCES (Non-Sensitive: Theme, Intro, UI State) ---

  static Future<bool> setString(String key, String value) async {
    // [STRICT] Jangan simpan token di sini!
    if (key == AppConstants.tokenKey) {
       print("⚠️ WARNING: Trying to save TOKEN via SharedPrefs! Use setToken() instead.");
       return false; 
    }
    final prefs = await _instance;
    return await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    if (key == AppConstants.tokenKey) {
       print("⚠️ WARNING: Trying to read TOKEN via SharedPrefs! Use getToken() instead.");
       return null; 
    }
    final prefs = await _instance; // Tunggu instance siap
    return prefs.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return await prefs.remove(key);
  }

  static Future<bool> clear() async {
    await _secureStorage.deleteAll(); // Clear secure tokens
    final prefs = await _instance;
    return await prefs.clear();
  }
}

