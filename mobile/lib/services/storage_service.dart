import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Getter ini menjamin _prefs selalu di-load sebelum dipakai
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance; // Tunggu instance siap
    return await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
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
    final prefs = await _instance;
    return await prefs.clear();
  }
}
