class AppConstants {
  static const String appName = 'Employee App';
    // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
  static const String baseUrl = 'http://20.25.3.211:3000/api'; // Physical Device

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String onboardSeenKey = 'onboard_seen';
  static const String firstLaunchKey = 'first_launch'; // TAMBAHKAN INI

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String loginPesertaEndpoint = '/auth/login-peserta';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String attendanceEndpoint = '/absensi';
  static const String activitiesEndpoint = '/logbook';

  // Splash Screen
  static const int splashDelay = 3000;

  // Other constants
  static const String appName = 'MyInternPlus';
}
