class ApiConfig {

  static const String baseUrl = 'http://10.140.239.224:3000/api'; // IP address WiFi Anda
  static const String uploadsUrl = 'http://10.140.239.224:3000/uploads';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String loginPesertaMagang = '$baseUrl/auth/login-peserta';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  
  // Dashboard endpoints
  static const String dashboard = '$baseUrl/dashboard';
  static const String dailyStats = '$baseUrl/dashboard/daily-stats';
  
  // Absensi endpoints
  static const String absensi = '$baseUrl/absensi';
  static const String checkIn = '$baseUrl/absensi/check-in';
  static const String checkOut = '$baseUrl/absensi/check-out';
  static const String absensiHistory = '$baseUrl/absensi/history';
  static const String absensiStats = '$baseUrl/absensi/stats';
  
  // Pengajuan Izin endpoints
  static const String pengajuanIzin = '$baseUrl/pengajuan-izin';
  static const String createIzin = '$baseUrl/pengajuan-izin';
  static const String izinHistory = '$baseUrl/pengajuan-izin/history';
  
  // User/Profil endpoints
  static const String profile = '$baseUrl/auth/profile';
  static const String updateProfile = '$baseUrl/auth/profile';
  static const String changePassword = '$baseUrl/peserta-magang/change-password';
  static const String uploadAvatar = '$baseUrl/auth/upload-avatar';
  
  // Settings endpoints
  static const String settings = '$baseUrl/settings';
  static const String notifications = '$baseUrl/settings/notifications';
  
  // Timeout configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

