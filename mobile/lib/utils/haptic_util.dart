import 'package:flutter/services.dart';

class HapticUtil {
  /// Getaran ringan untuk tap tombol biasa, switch tab, navigasi
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Getaran sedang untuk deteksi QR, konfirmasi dialog, atau aksi penting
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Getaran berat untuk Validasi Gagal, Error Fatal, atau Alert
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Getaran sukses (biasanya pola 'tup-tup' di iOS/Android modern)
  /// Gunakan saat Absen Berhasil, Simpan Data Berhasil
  static void success() {
    HapticFeedback.selectionClick();
    // Fallback manual jika selectionClick terlalu lemah di beberapa device:
    // HapticFeedback.mediumImpact();
  }
}
