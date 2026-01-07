import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class AnnouncementData {
  final String title;
  final String body;
  final String timeAgo;
  final String? downloadUrl;

  const AnnouncementData({
    required this.title,
    required this.body,
    required this.timeAgo,
    this.downloadUrl,
  });
}

class AnnouncementCard extends StatelessWidget {
  final List<AnnouncementData> items;
  final void Function(AnnouncementData item)? onDownload;
  final void Function(AnnouncementData item)? onViewDetail;

  const AnnouncementCard({
    super.key,
    this.items = const [],
    this.onDownload,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer, // Warna kartu adaptif
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.5), // Border adaptif
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan icon dan judul "Pengumuman"
            Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  size: 20,
                  color: AppThemes.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengumuman Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface, // Text utama adaptif
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Empty state atau List semua announcement
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada pengumuman',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme
                              .onSurfaceVariant, // Text sekunder adaptif
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(items.length, (index) {
                final item = items[index];
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    _AnnouncementItem(
                      item: item,
                      onDownload: onDownload,
                      onViewDetail: onViewDetail,
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 12),
                      Divider(
                        color: colorScheme.outline.withOpacity(0.2),
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementItem extends StatelessWidget {
  final AnnouncementData item;
  final void Function(AnnouncementData item)? onDownload;
  final void Function(AnnouncementData item)? onViewDetail;

  const _AnnouncementItem({
    required this.item,
    this.onDownload,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Body/Message
        Text(
          item.body,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Time Ago
        Text(
          item.timeAgo,
          style: const TextStyle(
            fontSize: 12,
            color: AppThemes.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Action Buttons
        if (item.downloadUrl != null || onViewDetail != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.downloadUrl != null)
                OutlinedButton.icon(
                  onPressed: () => onDownload?.call(item),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Unduh'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppThemes.primaryColor,
                    ),
                    foregroundColor: AppThemes.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (onViewDetail != null)
                TextButton.icon(
                  onPressed: () => onViewDetail?.call(item),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Selengkapnya'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppThemes.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
