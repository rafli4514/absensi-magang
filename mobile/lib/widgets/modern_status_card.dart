import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class ModernStatusCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final String status;
  final bool isCompleted;
  final bool isDark;

  const ModernStatusCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.status,
    required this.isCompleted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color successColor = AppThemes.successColor;
    final Color warningColor = AppThemes.warningColor;

    final Color cardColor = isCompleted
        ? (isDark
              ? AppThemes.successDark.withOpacity(0.2)
              : AppThemes.successLight)
        : (isDark
              ? AppThemes.warningDark.withOpacity(0.2)
              : AppThemes.warningLight);

    final Color iconColor = isCompleted ? successColor : warningColor;
    final Color badgeColor = isCompleted ? successColor : warningColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(color: AppThemes.darkOutline.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemes.darkSurface
                      : AppThemes.surfaceColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                size: 12,
                color: isCompleted ? successColor : warningColor,
              ),
              const SizedBox(width: 4),
              Text(
                isCompleted ? 'On time' : 'Not checked',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? successColor : warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
