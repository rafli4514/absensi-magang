import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_router.dart';
import 'navigation/route_names.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/onboard_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
// import 'services/storage_service.dart'; // Tidak perlu import jika tidak dipanggil langsung di main
import 'themes/app_themes.dart';
import 'utils/global_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HAPUS ATAU KOMENTAR BARIS INI:
  // await StorageService.init();

  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
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

            // --- INTEGRASI GLOBAL KEYS ---
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
