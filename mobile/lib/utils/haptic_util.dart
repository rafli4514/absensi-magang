import 'package:flutter/services.dart';

class HapticUtil {
  /// Getaran ringan untuk tap tombol biasa, switch tab
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Getaran sedang untuk sukses operasi (Clock In/Out, Save)
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Getaran berat untuk error fatal atau validasi gagal
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Getaran sukses (biasanya double tick di iOS)
  static void success() {
    HapticFeedback.selectionClick();
  }
}
