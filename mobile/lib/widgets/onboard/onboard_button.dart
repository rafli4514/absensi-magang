import 'package:flutter/material.dart';

import '../../themes/app_themes.dart';

class OnboardButton extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardButton({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Skip Button
        if (currentPage < pageCount - 1)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
            child: Text(
              'Lewati', // Translate
              style: TextStyle(
                color:
                    isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const Spacer(),
        // Next/Get Started Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
            ),
            child: Text(
              currentPage == pageCount - 1
                  ? 'Mulai Sekarang'
                  : 'Lanjut', // Translate
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
