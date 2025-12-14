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
            // Header dengan icon dan judul "Pengumuman"
            Row(
              children: [
                Icon(
                  Icons.announcement_rounded,
                  size: 20,
                  color: isDark
                      ? AppThemes.darkAccentBlue
                      : AppThemes.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengumuman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppThemes.darkTextPrimary
                        : AppThemes.onSurfaceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Empty state atau List semua announcement dalam 1 card
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.announcement_outlined,
                        size: 48,
                        color: isDark
                            ? AppThemes.darkTextSecondary.withOpacity(0.5)
                            : AppThemes.hintColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada pengumuman',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppThemes.darkTextSecondary
                              : AppThemes.hintColor,
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
                      isDark: isDark,
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 12),
                      Divider(
                        color: isDark
                            ? AppThemes.darkOutline
                            : AppThemes.hintColor.withOpacity(0.3),
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
  final bool isDark;

  const _AnnouncementItem({
    required this.item,
    this.onDownload,
    this.onViewDetail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          item.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),

        // Body/Message
        Text(
          item.body,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // Time Ago
        Text(
          item.timeAgo,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor,
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
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                    ),
                    foregroundColor: isDark
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              if (onViewDetail != null)
                TextButton.icon(
                  onPressed: () => onViewDetail?.call(item),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Lihat selengkapnya'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppThemes.darkAccentBlue
                        : AppThemes.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
