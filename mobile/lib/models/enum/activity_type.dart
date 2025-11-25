enum ActivityType {
  meeting('MEETING', 'Meeting', 0xFF2196F3),
  training('TRAINING', 'Training', 0xFFFF9800),
  presentation('PRESENTATION', 'Presentasi', 0xFF4CAF50),
  deadline('DEADLINE', 'Deadline', 0xFFF44336),
  other('OTHER', 'Lainnya', 0xFF9E9E9E);

  final String value;
  final String displayName;
  final int color;

  const ActivityType(this.value, this.displayName, this.color);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.other,
    );
  }
}
