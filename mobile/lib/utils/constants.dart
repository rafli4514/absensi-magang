class AppConstants {
  // Base URL
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // untuk Android emulator

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String onboardSeenKey = 'onboard_seen';
  static const String firstLaunchKey = 'first_launch'; // TAMBAHKAN INI

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String loginPesertaEndpoint = '/auth/login-peserta';
  static const String profileEndpoint = '/auth/profile';

  // Splash Screen
  static const int splashDelay = 3000;

  // Other constants
  static const String appName = 'MyInternPlus';
}
