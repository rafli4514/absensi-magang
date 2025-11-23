import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardPage1 extends StatelessWidget {
  const OnboardPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Updated container style like splash screen
          // App Logo
          Image.asset(
            'assets/images/Mascot1.png',
            width: 330,
            height: 330,
            fit: BoxFit.contain,
          ),
          Text(
            'MyInternPlus',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Your Attendance Management System',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : AppThemes.onSurfaceColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Manage your attendance and activities efficiently with our easy-to-use mobile application',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppThemes.darkTextTertiary : AppThemes.hintColor,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
