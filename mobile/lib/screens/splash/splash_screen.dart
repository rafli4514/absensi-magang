import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    _initializeApp();
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
      body: Center(
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
    );
  }
}
