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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemes.errorColor.withOpacity(0.1)
            : AppThemes.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppThemes.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppThemes.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? AppThemes.errorColor : AppThemes.errorDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.close, size: 18, color: AppThemes.errorColor),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
