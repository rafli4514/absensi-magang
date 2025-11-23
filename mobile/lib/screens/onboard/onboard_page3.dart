import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardPage3 extends StatelessWidget {
  const OnboardPage3({super.key});

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
          Image.asset(
            'assets/images/Mascot3.png',
            width: 360,
            height: 360,
            fit: BoxFit.contain,
          ),
          Text(
            'Track Your Performance',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Monitor your activities, attendance history, and performance metrics in real-time. Stay informed about your progress!',
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
