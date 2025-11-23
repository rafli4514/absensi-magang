import 'package:flutter/material.dart';

import '../../../models/onboard_model.dart';
import '../../../themes/app_themes.dart';

class OnboardPageWidget extends StatelessWidget {
  final OnboardModel model;

  const OnboardPageWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppThemes.darkBackground : AppThemes.surfaceColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Placeholder
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemes.darkSurface.withOpacity(0.5)
                  : model.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _getIconForPage(model, isDark),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              model.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              model.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconForPage(OnboardModel model, bool isDark) {
    if (model.title.contains('Welcome')) {
      return Icon(
        Icons.work_outline_rounded,
        size: 100,
        color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
      );
    } else if (model.title.contains('QR Code')) {
      return Icon(
        Icons.qr_code_scanner_rounded,
        size: 100,
        color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
      );
    } else {
      return Icon(
        Icons.bar_chart_rounded,
        size: 100,
        color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryDark,
      );
    }
  }
}
