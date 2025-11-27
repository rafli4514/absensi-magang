class AppConstants {
  static const String appName = 'MyInternPlus';

  // Pilih salah satu sesuai yang Anda gunakan SEKARANG:

  // UNCOMMENT salah satu di bawah ini:
  static const String baseUrl =
      'http://172.16.3.170:3000/api'; // Android Emulator
  // static const String baseUrl ='http://192.168.1.214:3000/api'; // Physical Device (IP Wi-Fi Anda)
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
  static const String attendanceEndpoint = '/absensi';
  static const String activitiesEndpoint = '/logbook';

  // Splash Screen
  static const int splashDelay = 3000;
}
