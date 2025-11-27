enum AttendanceStatus {
  valid('VALID', 'Valid', 0xFF4CAF50),
  terlambat('TERLAMBAT', 'Terlambat', 0xFFFF9800),
  invalid('INVALID', 'Invalid', 0xFFF44336),
  pending('PENDING', 'Pending', 0xFFFFC107);

  final String value;
  final String displayName;
  final int color;

  const AttendanceStatus(this.value, this.displayName, this.color);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.pending,
    );
  }
}
