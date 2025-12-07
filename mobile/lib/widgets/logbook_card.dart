import 'package:flutter/material.dart';

import '../../../models/logbook.dart';
import '../../../themes/app_themes.dart';

class LogBookCard extends StatelessWidget {
  final LogBook log;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogBookCard({
    super.key,
    required this.log,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppThemes.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: AppThemes.hintColor),
                color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _InfoBadge(icon: Icons.place, text: log.location, isDark: isDark),
              const SizedBox(width: 12),
              _InfoBadge(
                icon: Icons.person,
                text: log.mentorName,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            log.content,
            style: TextStyle(
              color: isDark
                  ? AppThemes.darkTextSecondary
                  : AppThemes.onSurfaceColor.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppThemes.hintColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
