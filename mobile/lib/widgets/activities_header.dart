import 'package:flutter/material.dart';

import '../../../themes/app_themes.dart';

class ActivitiesHeader extends StatelessWidget {
  final VoidCallback onAddActivity;
  final VoidCallback onAddLogbook;

  const ActivitiesHeader({
    super.key,
    required this.onAddActivity,
    required this.onAddLogbook,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Aktivitas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau progres harianmu',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderActionButton(
              icon: Icons.add_task,
              label: 'Aktivitas',
              onTap: onAddActivity,
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _HeaderActionButton(
              icon: Icons.book_outlined,
              label: 'Log Book',
              onTap: onAddLogbook,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppThemes.primaryColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.onSurfaceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
