class PerformanceStats {
  final int presentDays;
  final int totalDays;

  PerformanceStats({
    required this.presentDays,
    required this.totalDays,
  });

  factory PerformanceStats.empty() {
    return PerformanceStats(
      presentDays: 0,
      totalDays: 0,
    );
  }

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      presentDays: json['presentDays'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'presentDays': presentDays,
      'totalDays': totalDays,
    };
  }
}

