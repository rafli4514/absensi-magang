class PerformanceStats {
  final int presentDays;
  final int totalDays;
  final double percentage;
  final bool targetAchieved;

  PerformanceStats({
    required this.presentDays,
    required this.totalDays,
    required this.percentage,
    required this.targetAchieved,
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    final present = json['presentDays'] ?? 0;
    final total = json['totalDays'] ?? 0;
    final percentage = total > 0 ? (present / total * 100) : 0.0;
    final targetAchieved = percentage >= 85;

    return PerformanceStats(
      presentDays: present,
      totalDays: total,
      percentage: percentage,
      targetAchieved: targetAchieved,
    );
  }

  factory PerformanceStats.empty() {
    return PerformanceStats(
      presentDays: 0,
      totalDays: 0,
      percentage: 0,
      targetAchieved: false,
    );
  }
}

