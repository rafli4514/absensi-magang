import 'package:flutter/foundation.dart';

/// Central configuration for app environment
class AppConfig {
  // Platform Detection
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
  
  // Base URL Strategy
  static String get baseUrl {
    if (kIsWeb) {
      // Web: Use localhost in dev, production URL in build
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      );
    } else {
      // Mobile platform
      if (kDebugMode) {
        // Development mode
        // Android Emulator: 10.0.2.2
        // iOS Simulator: localhost works
        // Real Device: Use IP LAN address
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://10.0.2.2:3000',
        );
      } else {
        // Production
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.yourdomain.com',
        );
      }
    }
  }
  
  // API Endpoints
  static String get apiUrl => '$baseUrl/api';
  static String get uploadsUrl => '$baseUrl/uploads';
}
