import 'dart:async';

import 'package:flutter/material.dart';

import '../models/enum/activity_type.dart'; // Pastikan import ini ada
import '../themes/app_themes.dart';
import '../widgets/custom_dialog.dart';
import 'global_context.dart';
import 'haptic_util.dart';

// --- HELPER FUNCTIONS (Diletakkan di tingkat atas) ---

Color getActivityColor(ActivityType type) {
  return type.color;
}

Color getActivityTextColor(ActivityType type) {
  switch (type) {
    case ActivityType.sakit:
    case ActivityType.alpha:
    case ActivityType.deadline:
      return Colors.red.shade900;
    case ActivityType.izin:
    case ActivityType.meeting:
      return Colors.blue.shade900;
    case ActivityType.cuti:
      return Colors.purple.shade900;
    case ActivityType.pulangCepat:
    case ActivityType.training:
      return Colors.orange.shade900;
    case ActivityType.presentation:
      return Colors.green.shade900;
    default:
      return Colors.grey.shade900;
  }
}

// --- CLASSES ---

class GlobalSnackBar {
  static OverlayEntry? _overlayEntry;
  static Timer? _closeTimer;

  static void show(
    String message, {
    String? title,
    bool isSuccess = false,
    bool isError = false,
    bool isWarning = false,
    bool isInfo = false,
    IconData? icon,
  }) {
    _removeCurrentOverlay();

    final context = GlobalContext.navigatorKey.currentContext;
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;

    Color strokeColor = AppThemes.infoColor;
    Color iconBgColor =
        isDark ? AppThemes.infoColor.withOpacity(0.15) : AppThemes.infoLight;
    IconData defaultIcon = Icons.info_outline_rounded;
    String defaultTitle = 'Informasi';

    if (isSuccess) {
      strokeColor = AppThemes.successColor;
      iconBgColor = isDark
          ? AppThemes.successColor.withOpacity(0.15)
          : AppThemes.successLight;
      defaultIcon = Icons.check_circle_outline_rounded;
      defaultTitle = 'Sukses';
      HapticUtil.success();
    } else if (isError) {
      strokeColor = AppThemes.errorColor;
      iconBgColor = isDark
          ? AppThemes.errorColor.withOpacity(0.15)
          : AppThemes.errorLight;
      defaultIcon = Icons.error_outline_rounded;
      defaultTitle = 'Gagal';
      HapticUtil.error();
    } else if (isWarning) {
      strokeColor = AppThemes.warningColor;
      iconBgColor = isDark
          ? AppThemes.warningColor.withOpacity(0.15)
          : AppThemes.warningLight;
      defaultIcon = Icons.warning_amber_rounded;
      defaultTitle = 'Peringatan';
      HapticUtil.medium();
    } else {
      HapticUtil.light();
    }

    final IconData finalIcon = icon ?? defaultIcon;
    final navigatorState = GlobalContext.navigatorKey.currentState;
    if (navigatorState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(
        title: title ?? defaultTitle,
        message: message,
        icon: finalIcon,
        strokeColor: strokeColor,
        iconBackgroundColor: iconBgColor,
        onDismiss: _removeCurrentOverlay,
      ),
    );

    navigatorState.overlay?.insert(_overlayEntry!);

    _closeTimer = Timer(Duration(milliseconds: isError ? 4000 : 3000), () {
      _removeCurrentOverlay();
    });
  }

  static void _removeCurrentOverlay() {
    _closeTimer?.cancel();
    _closeTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color strokeColor;
  final Color iconBackgroundColor;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.strokeColor,
    required this.iconBackgroundColor,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? AppThemes.darkSurfaceElevated : Colors.white;
    final titleColor =
        isDark ? AppThemes.darkTextPrimary : AppThemes.onSurfaceColor;
    final messageColor =
        isDark ? AppThemes.darkTextSecondary : AppThemes.hintColor;
    final borderColor = isDark ? AppThemes.darkOutline : Colors.transparent;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : widget.strokeColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.strokeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: messageColor,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Icon(
                      Icons.close,
                      color:
                          isDark ? AppThemes.darkTextTertiary : Colors.black45,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppDialog {
  static void show(
    BuildContext? context, {
    required String title,
    required String content,
    String? primaryText,
    String? secondaryText,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool isError = false,
    bool dismissible = true,
  }) {
    if (isError) HapticUtil.error();

    if (context != null) {
      showDialog(
        context: context,
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
      return;
    }

    final navigator = GlobalContext.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      DialogRoute(
        context: navigator.context,
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
      ),
    );
  }
}

class AppToast {
  static void show(String message) {
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
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      try {
        overlayEntry.remove();
      } catch (e) {
        // Ignore
      }
    });
  }
}
