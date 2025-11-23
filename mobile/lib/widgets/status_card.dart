import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 2,
      color: isDark ? AppThemes.darkSurface : theme.cardTheme.color,
      shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
