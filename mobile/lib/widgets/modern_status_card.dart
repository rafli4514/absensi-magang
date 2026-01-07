import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class ModernStatusCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final String status;
  final bool isCompleted;

  // Hapus isDark dari constructor
  const ModernStatusCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.status,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final activeColor =
        isCompleted ? AppThemes.successColor : AppThemes.warningColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Otomatis Putih/Abu Gelap
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? activeColor.withOpacity(0.5)
              : colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: activeColor, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant, // Teks sekunder
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, // Teks utama
            ),
          ),
        ],
      ),
    );
  }
}
