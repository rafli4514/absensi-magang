// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true; // Default true agar main.dart menunggu

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final savedTheme =
          await StorageService.getString(AppConstants.themeModeKey);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        final themeString = savedTheme.replaceAll('ThemeMode.', '');
        _themeMode = _parseThemeMode(themeString);
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (error) {
      debugPrint('Error loading theme: $error');
      _themeMode = ThemeMode.system;
    } finally {
      // Delay sangat singkat untuk memastikan UI thread siap
      await Future.delayed(const Duration(milliseconds: 50));
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
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // Update UI langsung agar responsif
    try {
      await StorageService.setString(
        AppConstants.themeModeKey,
        mode.toString().replaceAll('ThemeMode.', ''),
      );
    } catch (error) {
      debugPrint('Error saving theme: $error');
    }
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
}
