import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      _isLoading = true;
      notifyListeners();

      final savedTheme = await StorageService.getString(
        AppConstants.themeModeKey,
      );
      if (savedTheme != null && savedTheme.isNotEmpty) {
        // Remove unnecessary parts from the string and parse safely
        final themeString = savedTheme.replaceAll('ThemeMode.', '');
        _themeMode = _parseThemeMode(themeString);
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (error) {
      print('Error loading theme preference: $error');
      _themeMode = ThemeMode.system;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      // Save only the simple string representation
      await StorageService.setString(
        AppConstants.themeModeKey,
        mode.toString().replaceAll('ThemeMode.', ''),
      );
      notifyListeners();
    } catch (error) {
      print('Error saving theme preference: $error');
      // Still update the UI even if storage fails
      notifyListeners();
    }
  }

  // Helper methods for easier theme management
  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode {
    return _themeMode == ThemeMode.system;
  }

  // Quick theme switching methods
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
