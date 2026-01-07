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

  // Factory methods tetap sama, hanya teruskan ke constructor
  factory CustomDialog.download(
      {required String fileName,
      required VoidCallback onDownload,
      VoidCallback? onCancel}) {
    return CustomDialog(
      title: 'Unduh File',
      content: 'Unduh $fileName?',
      primaryButtonText: 'Unduh',
      secondaryButtonText: 'Batal',
      primaryButtonColor: AppThemes.primaryColor,
      onPrimaryButtonPressed: onDownload,
      onSecondaryButtonPressed: onCancel,
      icon: Icons.download_rounded,
      type: DialogType.download,
    );
  }

  factory CustomDialog.detail(
      {required String title,
      required String description,
      VoidCallback? onClose}) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = primaryButtonColor ?? AppThemes.primaryColor;

    return Dialog(
      backgroundColor: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: type == DialogType.download
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: accentColor),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: type == DialogType.download
                  ? TextAlign.center
                  : TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
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
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryButtonText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryButtonPressed ??
                          () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: accentColor),
                        foregroundColor: accentColor,
                      ),
                      child: Text(secondaryButtonText!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        onPrimaryButtonPressed ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
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
