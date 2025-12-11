import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? primaryButtonColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.primaryButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppThemes.darkOutline : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.onSurfaceColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: onSecondaryButtonPressed ??
                          () => Navigator.pop(context),
                      child: Text(
                        secondaryButtonText!,
                        style: TextStyle(
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        onPrimaryButtonPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor ??
                          (isDark
                              ? AppThemes.darkAccentBlue
                              : AppThemes.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(primaryButtonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
