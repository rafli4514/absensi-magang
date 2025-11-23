class AppConstants {
  static const String appName = 'Employee App';
  static const String baseUrl = 'https://your-api-url.com';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String onboardSeenKey = 'onboard_seen';
  static const String themeModeKey = 'theme_mode';

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String attendanceEndpoint = '/attendance';
  static const String activitiesEndpoint = '/activities';

  // Time constants
  static const int splashDelay = 2000;
}

class AssetPaths {
  static const String onboard1 = 'assets/images/onboard1.png';
  static const String onboard2 = 'assets/images/onboard2.png';
  static const String onboard3 = 'assets/images/onboard3.png';
  static const String logo = 'assets/images/logo.png';
}
