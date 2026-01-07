import 'package:flutter/material.dart';

import '../../models/logbook.dart';
import '../../themes/app_themes.dart';

class LogBookCard extends StatelessWidget {
  final LogBook log;
  final VoidCallback? onEdit; // Ubah jadi Nullable
  final VoidCallback? onDelete; // Ubah jadi Nullable
  final bool isReadOnly; // Tambah flag ReadOnly

  const LogBookCard({
    super.key,
    required this.log,
    this.onEdit,
    this.onDelete,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        boxShadow: isLight
            ? [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]
            : [],
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
                child: const Icon(Icons.menu_book_rounded,
                    color: AppThemes.primaryColor, size: 20),
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
                          color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.tanggal,
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    if (log.durasi != null && log.durasi!.isNotEmpty)
                      Text(
                        'Durasi: ${log.durasi}',
                        style: TextStyle(
                            fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),

              // HANYA TAMPILKAN MENU JIKA TIDAK READ-ONLY
              if (!isReadOnly && onEdit != null && onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: colorScheme.onSurfaceVariant),
                  color: colorScheme.surfaceContainer,
                  onSelected: (value) {
                    if (value == 'edit') onEdit!();
                    if (value == 'delete') onDelete!();
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              size: 18, color: colorScheme.onSurface),
                          const SizedBox(width: 8),
                          Text('Ubah',
                              style: TextStyle(color: colorScheme.onSurface)),
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
                color: colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14,
                height: 1.4),
          ),
        ],
      ),
    );
  }
}
