class DashboardModel {
  final String userName;
  final String? todayStatus;
  final String? checkInTime;
  final String? checkOutTime;
  final DashboardStats? stats;
  final List<ScheduleItem>? schedule;

  DashboardModel({
    required this.userName,
    this.todayStatus,
    this.checkInTime,
    this.checkOutTime,
    this.stats,
    this.schedule,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      userName: json['userName'] ?? json['user_name'] ?? '',
      todayStatus: json['todayStatus'] ?? json['today_status'],
      checkInTime: json['checkInTime'] ?? json['check_in_time'],
      checkOutTime: json['checkOutTime'] ?? json['check_out_time'],
      stats: json['stats'] != null
          ? DashboardStats.fromJson(json['stats'])
          : null,
      schedule: json['schedule'] != null
          ? (json['schedule'] as List)
              .map((e) => ScheduleItem.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'todayStatus': todayStatus,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'stats': stats?.toJson(),
      'schedule': schedule?.map((e) => e.toJson()).toList(),
    };
  }
}

class DashboardStats {
  final int totalHadir;
  final int totalTerlambat;
  final int totalIzin;
  final int totalAlpha;

  DashboardStats({
    required this.totalHadir,
    required this.totalTerlambat,
    required this.totalIzin,
    required this.totalAlpha,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalHadir: json['totalHadir'] ?? json['total_hadir'] ?? 0,
      totalTerlambat: json['totalTerlambat'] ?? json['total_terlambat'] ?? 0,
      totalIzin: json['totalIzin'] ?? json['total_izin'] ?? 0,
      totalAlpha: json['totalAlpha'] ?? json['total_alpha'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHadir': totalHadir,
      'totalTerlambat': totalTerlambat,
      'totalIzin': totalIzin,
      'totalAlpha': totalAlpha,
    };
  }
}

class ScheduleItem {
  final String time;
  final String title;
  final String? description;

  ScheduleItem({
    required this.time,
    required this.title,
    this.description,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'title': title,
      'description': description,
    };
  }
}

