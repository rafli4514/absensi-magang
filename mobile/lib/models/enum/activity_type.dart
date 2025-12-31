import 'package:flutter/material.dart';

enum ActivityType {
  // --- AKTIVITAS KERJA ---
  meeting('MEETING', 'Meeting', 0xFF2196F3),
  training('TRAINING', 'Training', 0xFFFF9800),
  presentation('PRESENTATION', 'Presentasi', 0xFF4CAF50),
  deadline('DEADLINE', 'Deadline', 0xFFF44336),

  // --- TIPE IZIN ---
  sakit('SAKIT', 'Sakit', 0xFFE57373), // Merah Muda
  izin('IZIN', 'Izin', 0xFF64B5F6), // Biru Muda
  cuti('CUTI', 'Cuti', 0xFFBA68C8), // Ungu
  pulangCepat('PULANG_CEPAT', 'Pulang Cepat', 0xFFFFB74D), // Orange
  alpha('ALPHA', 'Alpha', 0xFFD32F2F), // Merah Tua

  // --- LAINNYA (Fixed Value: 'LAINNYA' agar sinkron dengan backend) ---
  other('LAINNYA', 'Lainnya', 0xFF9E9E9E);

  final String value;
  final String displayName;
  final int colorInt;

  const ActivityType(this.value, this.displayName, this.colorInt);

  // Helper untuk mendapatkan Color object langsung
  Color get color => Color(colorInt);

  static ActivityType fromString(String value) {
    // Handle mapping jika backend mengirim 'OTHER' atau 'LAINNYA'
    if (value == 'OTHER') return ActivityType.other;

    return ActivityType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => ActivityType.other,
    );
  }
}
