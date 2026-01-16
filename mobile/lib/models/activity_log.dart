class ActivityLog {
  final String id;
  final String userId;
  final UserPreview? user;
  final String action;
  final String entityType;
  final String? entityId;
  final String description;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    this.user,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['userId'],
      user: json['user'] != null ? UserPreview.fromJson(json['user']) : null,
      action: json['action'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserPreview {
  final String username;
  final String? avatar;
  final String role;

  UserPreview({
    required this.username,
    this.avatar,
    required this.role,
  });

  factory UserPreview.fromJson(Map<String, dynamic> json) {
    return UserPreview(
      username: json['username'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }
}
