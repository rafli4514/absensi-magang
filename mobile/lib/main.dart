// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'navigation/app_router.dart';
import 'navigation/route_names.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/onboard_provider.dart';
import 'providers/theme_provider.dart';
import 'services/app_config_service.dart';
import 'services/notification_service.dart';
import 'themes/app_themes.dart';
import 'utils/constants.dart';
import 'utils/global_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Set status bar transparan agar UI lebih clean
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  try {
    AppConstants.baseUrl = await AppConfigService.initBaseUrl();
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint('❌ Initialization Failed: $e');
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
          // --- FIX UTAMA: Tahan render sampai tema siap ---
          if (themeProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Colors.white, // Atau warna netral
                body: Center(
                    child: SizedBox()), // Layar kosong saat loading detik awal
              ),
            );
          }

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
