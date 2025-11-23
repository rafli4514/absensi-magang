import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_router.dart';
import '../navigation/route_names.dart';
import '../providers/attendance_provider.dart'; // IMPORT BARU
import '../providers/auth_provider.dart';
import '../providers/onboard_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
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
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(),
        ), // TAMBAH INI
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MyInternPlus',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
