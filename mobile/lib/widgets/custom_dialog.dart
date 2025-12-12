import 'package:flutter/material.dart';

import '../themes/app_themes.dart';

enum DialogType { standard, download, detail }

class CustomDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? primaryButtonColor;
  final IconData? icon;
  final DialogType type;

  // Constructor Utama (Standard)
  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.primaryButtonColor,
    this.icon,
    this.type = DialogType.standard,
  });

  // Factory: Download Dialog
  factory CustomDialog.download({
    required String fileName,
    required VoidCallback onDownload,
    VoidCallback? onCancel,
  }) {
    return CustomDialog(
      title: 'Download $fileName',
      content: 'Apakah Anda yakin ingin mendownload $fileName?',
      primaryButtonText: 'Download',
      secondaryButtonText: 'Batal',
      primaryButtonColor: AppThemes.primaryColor,
      onPrimaryButtonPressed: onDownload,
      onSecondaryButtonPressed: onCancel,
      icon: Icons.download_rounded,
      type: DialogType.download,
    );
  }

  // Factory: Detail Dialog
  factory CustomDialog.detail({
    required String title,
    required String description,
    VoidCallback? onClose,
  }) {
    return CustomDialog(
      title: title,
      content: description,
      primaryButtonText: 'Tutup',
      onPrimaryButtonPressed: onClose,
      primaryButtonColor: AppThemes.primaryColor,
      icon: Icons.info_outline_rounded,
      type: DialogType.detail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tentukan warna aksen berdasarkan mode
    final accentColor = primaryButtonColor ??
        (isDark ? AppThemes.darkAccentBlue : AppThemes.primaryColor);

    return Dialog(
      backgroundColor: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppThemes.darkOutline, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: type == DialogType.download
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            if (type == DialogType.download && icon != null) ...[
              // Layout Download: Icon Besar di Tengah
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                ),
              ),
            ] else if (type == DialogType.detail && icon != null) ...[
              // Layout Detail: Icon Kecil di Samping Judul
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppThemes.darkTextPrimary
                            : AppThemes.onSurfaceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Layout Standard: Judul Saja
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // --- CONTENT SECTION ---
            if (contentWidget != null)
              contentWidget!
            else if (content != null)
              Text(
                content!,
                textAlign: type == DialogType.download
                    ? TextAlign.center
                    : TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppThemes.darkTextSecondary
                      : AppThemes.onSurfaceColor.withOpacity(0.8),
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 24),

            // --- BUTTONS SECTION ---
            Row(
              children: [
                // Secondary Button (Optional)
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: type == DialogType.download
                        ? OutlinedButton(
                            onPressed: onSecondaryButtonPressed ??
                                () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(color: accentColor),
                              foregroundColor: accentColor,
                            ),
                            child: Text(secondaryButtonText!),
                          )
                        : TextButton(
                            onPressed: onSecondaryButtonPressed ??
                                () => Navigator.pop(context),
                            child: Text(
                              secondaryButtonText!,
                              style: TextStyle(
                                color: isDark
                                    ? AppThemes.darkTextSecondary
                                    : AppThemes.hintColor,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Primary Button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        onPrimaryButtonPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(primaryButtonText ?? 'OK'),
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
