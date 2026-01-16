import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Import Provider & Router
import 'navigation/auth_gate.dart';
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

import 'services/auth_service.dart'; // [IMPORT AUTH SERVICE]

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // [PENTING] Init Config DULU sebelum Auth/API
  await AppConfigService.init();

  // [PENTING] Init Auth State sebelum App Jalan
  await AuthService.init();
  await OnboardProvider.init();

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
            home: const AuthGate(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
