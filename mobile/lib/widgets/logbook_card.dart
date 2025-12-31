import 'package:flutter/material.dart';

import '../../models/logbook.dart';
import '../../themes/app_themes.dart';
import '../utils/ui_utils.dart';

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
                      log.kegiatan,
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
                      log.tanggal,
                      style: TextStyle(
                        fontSize: 12,
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

              // Badges Type & Status
              if (log.type != null || log.status != null) ...[
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (log.type != null)
                      _buildBadge(
                        text: log.type!.displayName,
                        // PERBAIKAN DISINI: ubah 'item' menjadi 'log'
                        color: getActivityColor(log.type!),
                      ),
                    if (log.status != null)
                      _buildBadge(
                        text: log.status!.displayName,
                        // Pastikan status.color berupa int (0xFF...) atau Color object
                        // Jika status.color sudah int, gunakan Color(log.status!.color)
                        color: Color(log.status!.color),
                      ),
                  ],
                ),
              ],

              // Popup Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: isDark
                        ? AppThemes.darkTextSecondary
                        : AppThemes.hintColor),
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
                        Text('Ubah',
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
                        Text('Hapus',
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

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
