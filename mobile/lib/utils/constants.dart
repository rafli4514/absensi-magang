class AppConstants {
  static const String appName = 'Employee App';
    // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
  static const String baseUrl = 'http://20.25.3.211:3000/api'; // Physical Device

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String onboardSeenKey = 'onboard_seen';
  static const String themeModeKey = 'theme_mode';

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String loginPesertaEndpoint = '/auth/login-peserta';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String attendanceEndpoint = '/absensi';
  static const String activitiesEndpoint = '/logbook';

  // Time constants
  static const int splashDelay = 2000;
}

class AssetPaths {
  static const String onboard1 = 'assets/images/onboard1.png';
  static const String onboard2 = 'assets/images/onboard2.png';
  static const String onboard3 = 'assets/images/onboard3.png';
  static const String logo = 'assets/images/logo.png';
}
