import 'package:flutter/material.dart';

// Hapus import fluttertoast jika tidak dipakai, atau biarkan jika ada dependensi lain
// import 'package:fluttertoast/fluttertoast.dart';

import '../themes/app_themes.dart';
import '../widgets/custom_dialog.dart';
import 'global_context.dart';
import 'haptic_util.dart';

class GlobalSnackBar {
  static void show(
    String message, {
    Color? color,
    IconData? icon,
    bool isSuccess = false,
    bool isError = false,
    bool isWarning = false,
  }) {
    // Gunakan ScaffoldMessenger key secara langsung untuk keamanan
    final messenger = GlobalContext.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // Tentukan context hanya untuk tema (opsional, bisa fallback)
    final context = GlobalContext.navigatorKey.currentContext;
    final isDark = context != null
        ? Theme.of(context).brightness == Brightness.dark
        : false;

    // Tentukan warna dan icon otomatis jika tidak di-set
    Color finalColor = color ?? AppThemes.infoColor;
    IconData finalIcon = icon ?? Icons.info_outline_rounded;

    if (isSuccess) {
      finalColor = AppThemes.successColor;
      finalIcon = Icons.check_circle_rounded;
    } else if (isError) {
      finalColor = AppThemes.errorColor;
      finalIcon = Icons.cancel_rounded;
      HapticUtil.error(); // Auto haptic on error
    } else if (isWarning) {
      finalColor = AppThemes.warningColor;
      finalIcon = Icons.warning_amber_rounded;
    }

    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor:
            isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: finalColor, width: 1.5),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: finalColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(finalIcon, color: finalColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark
                      ? AppThemes.darkTextPrimary
                      : AppThemes.onSurfaceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: Duration(milliseconds: isError ? 4000 : 2500),
      ),
    );
  }
}

class AppDialog {
  static void show(
    BuildContext? context, {
    // Context dibuat nullable
    required String title,
    required String content,
    String? primaryText,
    String? secondaryText,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool isError = false,
    bool dismissible = true,
  }) {
    // Gunakan context yang diberikan atau fallback ke navigator key
    final ctx = context ?? GlobalContext.navigatorKey.currentContext;
    if (ctx == null) return;

    if (isError) HapticUtil.error();

    showDialog(
      context: ctx,
      barrierDismissible: dismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        primaryButtonText: primaryText ?? 'OK',
        secondaryButtonText: secondaryText,
        onPrimaryButtonPressed: onPrimary,
        onSecondaryButtonPressed: onSecondary,
        primaryButtonColor:
            isError ? AppThemes.errorColor : AppThemes.primaryColor,
      ),
    );
  }
}

class AppToast {
  // Simple toast using Overlay
  static void show(String message) {
    // PERBAIKAN UTAMA DI SINI
    // Jangan gunakan Overlay.of(context) dengan global key navigator context
    // karena Navigator context tidak punya Overlay ancestor.
    // Gunakan currentState.overlay milik Navigator.
    final overlayState = GlobalContext.navigatorKey.currentState?.overlay;

    if (overlayState == null) return;

    HapticUtil.light();

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert ke overlay state navigator langsung
    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      // Cek mounted sebelum remove (opsional untuk OverlayEntry tapi aman)
      try {
        overlayEntry.remove();
      } catch (e) {
        // Ignore if already removed
      }
    });
  }
}
