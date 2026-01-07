import 'dart:async';

import 'package:flutter/material.dart';

import '../models/enum/activity_type.dart';
import '../themes/app_themes.dart';
import 'global_context.dart';
import 'haptic_util.dart';

Color getActivityColor(ActivityType type) => type.color;

// --- GLOBAL SNACKBAR ---
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
    if (context == null) return;

    Color typeColor = AppThemes.infoColor;
    IconData defaultIcon = Icons.info_outline_rounded;
    String defaultTitle = 'Informasi';

    if (isSuccess) {
      typeColor = AppThemes.successColor;
      defaultIcon = Icons.check_circle_outline_rounded;
      defaultTitle = 'Sukses';
      HapticUtil.success();
    } else if (isError) {
      typeColor = AppThemes.errorColor;
      defaultIcon = Icons.error_outline_rounded;
      defaultTitle = 'Gagal';
      HapticUtil.error();
    } else if (isWarning) {
      typeColor = AppThemes.warningColor;
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
        color: typeColor,
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
  final Color color;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
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
        duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, -1.0), end: const Offset(0.0, 0.0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Theme Context untuk background
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              // ADAPTIF: Putih di Light, Abu Gelap di Dark
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(widget.message,
                          style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Icon(Icons.close,
                        color: colorScheme.onSurfaceVariant, size: 20),
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
