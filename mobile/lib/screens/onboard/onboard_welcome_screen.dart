import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';

class OnboardWelcomeScreen extends StatelessWidget {
  const OnboardWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppThemes.darkBackground
          : AppThemes
                .backgroundColor, // Changed to backgroundColor for better contrast
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo dengan gradient
              Image.asset(
                'assets/images/Mascot4.png',
                width: 360,
                height: 360,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'Ready to Get Started?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Start managing your attendance and activities with our easy-to-use app',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.hintColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Get Started Button - Fixed styling
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RouteNames.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Consistent border radius
                    ),
                    shadowColor: AppThemes.primaryColor.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Create Account Button - Fixed styling
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteNames.register,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                    side: BorderSide(
                      color: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Consistent border radius
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
