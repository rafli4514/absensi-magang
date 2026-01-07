import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Import Provider & Router
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/onboard_provider.dart';
import 'providers/theme_provider.dart';
// [PENTING] Import Service & Utils
import 'services/app_config_service.dart'; // <--- JANGAN LUPA INI
import 'services/notification_service.dart';
import 'themes/app_themes.dart';
import 'utils/constants.dart';
import 'utils/global_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Notifikasi
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint('❌ Failed to initialize notifications: $e');
  }

  // [PENTING] Inisialisasi URL
  try {
    AppConstants.baseUrl = await AppConfigService.initBaseUrl();
    debugPrint('🌐 Configured Base URL: ${AppConstants.baseUrl}');
  } catch (e) {
    // Fallback darurat (Ganti IP sesuai kebutuhan)
    AppConstants.baseUrl = 'http://192.168.1.8:3000/api';
    debugPrint(
        '⚠️ Error initBaseUrl: $e. Using fallback: ${AppConstants.baseUrl}');
  }

  try {
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Jadwalkan pengingat absen rutin
    await notificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint('❌ Failed to initialize notifications: $e');
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
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            navigatorKey: GlobalContext.navigatorKey,
            scaffoldMessengerKey: GlobalContext.scaffoldMessengerKey,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
