import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

class DownloadDialog extends StatelessWidget {
  final String fileName;
  final VoidCallback onDownload;

  const DownloadDialog({
    super.key,
    required this.fileName,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
            : BorderSide.none,
      ),
      backgroundColor: isDark ? AppThemes.darkSurface : Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor)
                        .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                size: 32,
                color: isDark
                    ? AppThemes.darkAccentBlue
                    : AppThemes.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Download $fileName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppThemes.darkTextPrimary
                    : AppThemes.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin mendownload $fileName?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppThemes.darkTextSecondary
                    : AppThemes.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: isDark
                            ? AppThemes.darkAccentBlue
                            : AppThemes.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDownload();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isDark
                          ? AppThemes.darkAccentBlue
                          : AppThemes.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Download',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
