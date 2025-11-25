class User {
  final String id;
  final String username;
  final String? nama;
  final String role;
  final bool isActive;
  final String? avatar;
  final String? divisi;
  final String? instansi;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    this.nama,
    required this.role,
    required this.isActive,
    this.avatar,
    this.divisi,
    this.instansi,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('🔍 User.fromJson received: $json');

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      nama: json['nama']?.toString(),
      role: json['role']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      avatar: json['avatar']?.toString(),
      divisi: json['divisi']?.toString(),
      instansi: json['instansi']?.toString(),
      token: json['token']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'role': role,
      'isActive': isActive,
      'avatar': avatar,
      'divisi': divisi,
      'instansi': instansi,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get name => nama ?? username;
  String get email => username;
  String get department => divisi ?? '';
  String get position => role;
  String? get profileImage => avatar;
}
