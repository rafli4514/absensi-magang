import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Imports
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
// Pastikan import ini sesuai dengan struktur folder Anda
// Jika main.dart ada di root 'lib/', gunakan path seperti ini:
import '../navigation/app_router.dart';
import '../navigation/route_names.dart';
import '../providers/attendance_provider.dart';
import '../providers/onboard_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart'; // Tambahkan Import ini
import '../services/storage_service.dart';
import '../themes/app_themes.dart';

// Fungsi test koneksi (Opsional, bisa dihapus saat production)
void testApiConnection() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/test'),
    );
    print('🔵 API Connection Test: ${response.statusCode}');
    print('🔵 API Response: ${response.body}');
  } catch (e) {
    print('❌ API Connection Failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Storage
  await StorageService.init();

  // 2. Inisialisasi Notification Service (BARU)
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Jadwalkan pengingat harian (07:45 & 16:45)
    await notificationService.scheduleDailyReminders();
    print('✅ Notification Service Initialized');
  } catch (e) {
    print('❌ Failed to initialize notifications: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => OnboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MyInternPlus',
            // Konfigurasi Tema
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,

            // Konfigurasi Debug & Routing
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
