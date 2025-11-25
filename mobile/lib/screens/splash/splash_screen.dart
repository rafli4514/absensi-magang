import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboard_provider.dart';
import '../../themes/app_themes.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String appVersion = 'V.1.0.0';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _initializeApp();
  }

  // Method untuk mendapatkan info versi aplikasi
  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Fallback jika gagal mendapatkan versi
      setState(() {
        appVersion = 'v1.0.0';
      });
    }
  }

  Future<void> _initializeApp() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDelay),
    );

    final onboardProvider = Provider.of<OnboardProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user has seen onboarding
    if (!onboardProvider.onboardCompleted) {
      Navigator.pushReplacementNamed(context, RouteNames.onboard);
      return;
    }

    // Check if user is authenticated
    final isAuthenticated = await authProvider.checkAuthentication();

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppThemes.darkBackground
          : AppThemes.surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten utama di tengah
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/InternLogoExpand.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Menggunakan LoadingIndicator
                  LoadingIndicator(message: 'Memuat...'),
                ],
              ),
            ),

            // Informasi versi dan copyright di bagian bawah
            Positioned(
              bottom: 24, // Jarak dari bawah
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Versi aplikasi
                  if (appVersion.isNotEmpty)
                    Text(
                      appVersion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Copyright
                  Text(
                    '© 2024 Aro Fakhrur Riziq. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black45,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
