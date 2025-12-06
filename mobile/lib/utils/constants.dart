class AppConstants {
  static const String appName = 'MyInternPlus';

  // Base URL
  static const String baseUrl =
      'http://10.140.251.98:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://10.140.251.98:3000/api'; // Physical Device
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String onboardSeenKey = 'onboard_seen';
  static const String firstLaunchKey = 'first_launch';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String loginPesertaEndpoint = '/auth/login-peserta';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // Settings & QR Endpoints
  static const String settingsEndpoint = '/settings';
  static const String qrEndpoint = '/qr';
  static const String attendanceEndpoint = '/attendance';
  static const String activitiesEndpoint = '/logbook';

  // Splash Screen
  static const int splashDelay = 3000;
}
