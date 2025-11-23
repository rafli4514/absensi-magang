import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemes.errorDark.withOpacity(0.2)
            : AppThemes.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppThemes.errorDark.withOpacity(0.4)
              : AppThemes.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: isDark ? AppThemes.errorLight : AppThemes.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? AppThemes.errorLight : AppThemes.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppThemes.errorLight : AppThemes.errorColor,
              size: 20,
            ),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
