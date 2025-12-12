import 'package:flutter/material.dart';

class AppLoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    // Jika overlay sudah ada, jangan tumpuk
    if (_overlayEntry != null) return;

    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Pastikan context masih valid (widget belum didispose)
      if (context.mounted) {
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _overlayEntry = null; // Reset jika context tidak valid
      }
    } catch (e) {
      debugPrint('❌ Gagal menampilkan loading overlay: $e');
      _overlayEntry = null;
    }
  }

  static void hide() {
    if (_overlayEntry == null) return;

    try {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
      }
    } catch (e) {
      debugPrint('⚠️ Overlay remove error (safe to ignore): $e');
    } finally {
      // Pastikan variabel di-reset ke null agar bisa dipakai lagi
      _overlayEntry = null;
    }
  }
}
