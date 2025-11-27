enum ActivityStatus {
  completed('COMPLETED', 'Selesai', 0xFF4CAF50),
  inProgress('IN_PROGRESS', 'Dalam Proses', 0xFFFF9800),
  pending('PENDING', 'Menunggu', 0xFFFFC107),
  cancelled('CANCELLED', 'Dibatalkan', 0xFFF44336);

  final String value;
  final String displayName;
  final int color;

  const ActivityStatus(this.value, this.displayName, this.color);

  static ActivityStatus fromString(String value) {
    return ActivityStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ActivityStatus.pending,
    );
  }
}
