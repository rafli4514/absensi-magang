import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/absensi_model.dart';
import '../models/user_model.dart';

class OfflineService {
  // Keys for local storage
  static const String _userDataKey = 'user_data';
  static const String _absensiHistoryKey = 'absensi_history';
  static const String _pendingAbsensiKey = 'pending_absensi';
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineModeKey = 'offline_mode';

  // Save user data locally
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userDataKey, userJson);
  }

  // Get user data from local storage
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userDataKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error getting user data from local storage: $e');
      return null;
    }
  }

  // Save absensi history locally
  static Future<void> saveAbsensiHistory(List<AbsensiModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_absensiHistoryKey, historyJson);
  }

  // Get absensi history from local storage
  static Future<List<AbsensiModel>> getAbsensiHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_absensiHistoryKey);
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        return historyList
            .map((e) => AbsensiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting absensi history from local storage: $e');
      return [];
    }
  }

  // Save pending absensi (for offline mode)
  static Future<void> savePendingAbsensi(AbsensiModel absensi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingList = await getPendingAbsensi();
      pendingList.add(absensi);
      
      final pendingJson = jsonEncode(pendingList.map((e) => e.toJson()).toList());
      await prefs.setString(_pendingAbsensiKey, pendingJson);
    } catch (e) {
      print('Error saving pending absensi: $e');
    }
  }

  // Get pending absensi
  static Future<List<AbsensiModel>> getPendingAbsensi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingAbsensiKey);
      if (pendingJson != null) {
        final pendingList = jsonDecode(pendingJson) as List<dynamic>;
        return pendingList
            .map((e) => AbsensiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting pending absensi: $e');
      return [];
    }
  }

  // Clear pending absensi
  static Future<void> clearPendingAbsensi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingAbsensiKey);
  }

  // Save last sync timestamp
  static Future<void> saveLastSync(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());
  }

  // Get last sync timestamp
  static Future<DateTime?> getLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      return null;
    } catch (e) {
      print('Error getting last sync: $e');
      return null;
    }
  }

  // Set offline mode
  static Future<void> setOfflineMode(bool isOffline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, isOffline);
  }

  // Check if in offline mode
  static Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  // Save any data locally with key
  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = jsonEncode(data);
      await prefs.setString(key, dataJson);
    } catch (e) {
      print('Error saving data with key $key: $e');
    }
  }

  // Get data from local storage with key
  static Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(key);
      if (dataJson != null) {
        return jsonDecode(dataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting data with key $key: $e');
      return null;
    }
  }

  // Remove data with key
  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all offline data
  static Future<void> clearAllOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_absensiHistoryKey);
    await prefs.remove(_pendingAbsensiKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_offlineModeKey);
  }

  // Check if data is stale (older than specified hours)
  static Future<bool> isDataStale(int hoursThreshold) async {
    final lastSync = await getLastSync();
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inHours > hoursThreshold;
  }

  // Get storage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    int totalSize = 0;
    for (String key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    
    return {
      'totalKeys': keys.length,
      'totalSize': totalSize,
      'lastSync': await getLastSync(),
      'isOfflineMode': await isOfflineMode(),
      'pendingAbsensiCount': (await getPendingAbsensi()).length,
    };
  }

  // Sync pending data when online
  static Future<void> syncPendingData() async {
    try {
      final pendingAbsensi = await getPendingAbsensi();
      if (pendingAbsensi.isNotEmpty) {
        // Here you would sync with the server
        // For now, we'll just clear the pending data
        await clearPendingAbsensi();
        await saveLastSync(DateTime.now());
      }
    } catch (e) {
      print('Error syncing pending data: $e');
    }
  }
}
