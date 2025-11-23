enum ActivityType {
  meeting,
  deadline,
  training,
  presentation,
  other,
}

enum ActivityStatus {
  completed,
  pending,
  upcoming,
  cancelled,
}

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ActivityType type;
  final ActivityStatus status;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.status,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.other,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ActivityStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }
}