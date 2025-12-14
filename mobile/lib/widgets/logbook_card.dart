import 'package:flutter/material.dart';

import '../../models/enum/activity_status.dart';
import '../../models/enum/activity_type.dart';
import '../../models/logbook.dart';
import '../../themes/app_themes.dart';

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
        // Integrasi Theme: Background Card
        color: isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Integrasi Theme: Border
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
                      log.kegiatan,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        // Integrasi Theme
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.tanggal,
                      style: TextStyle(
                        fontSize: 12,
                        // Integrasi Theme
                        color: isDark
                            ? AppThemes.darkTextSecondary
                            : AppThemes.hintColor,
                      ),
                    ),
                    if (log.durasi != null && log.durasi!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Durasi: ${log.durasi}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Type dan Status badges
              if (log.type != null || log.status != null) ...[
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (log.type != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(log.type!.color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color(log.type!.color).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          log.type!.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(log.type!.color),
                          ),
                        ),
                      ),
                    if (log.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(log.status!.color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color(log.status!.color).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          log.status!.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(log.status!.color),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              PopupMenuButton<String>(
                // Integrasi Theme: Icon Color
                icon: Icon(Icons.more_vert,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor),
                // Integrasi Theme: Popup Background
                color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit,
                            size: 18,
                            color: isDark ? AppThemes.darkTextPrimary : null),
                        const SizedBox(width: 8),
                        Text('Edit',
                            style: TextStyle(
                                color:
                                    isDark ? AppThemes.darkTextPrimary : null)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            size: 18, color: AppThemes.errorColor),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppThemes.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            log.deskripsi,
            style: TextStyle(
              // Integrasi Theme
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
        // Integrasi Theme: Badge Background
        color: isDark ? AppThemes.darkSurfaceVariant : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              // Integrasi Theme: Icon Color
              color:
                  isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              // Integrasi Theme: Text Color
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
