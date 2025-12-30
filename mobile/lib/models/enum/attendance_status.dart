enum AttendanceStatus {
  valid('VALID', 'Hadir', 0xFF4CAF50), // Hijau
  terlambat('TERLAMBAT', 'Terlambat', 0xFFFF9800), // Orange
  invalid('INVALID', 'Invalid', 0xFFF44336), // Merah
  pending('PENDING', 'Pending', 0xFF9E9E9E), // Abu-abu

  // --- TAMBAHAN YANG BENAR ---
  sakit('SAKIT', 'Sakit', 0xFF2196F3), // Biru (Info)
  izin('IZIN', 'Izin', 0xFFFFC107), // Kuning/Amber
  alpha('ALPHA', 'Tanpa Keterangan', 0xFFF44336); // Merah (Error)

  final String value;
  final String displayName;
  final int color;

  const AttendanceStatus(this.value, this.displayName, this.color);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value.toUpperCase() == value.toUpperCase(),
      orElse: () => AttendanceStatus.pending,
    );
  }
}
