class User {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String? profileImage;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    this.profileImage,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      profileImage: json['profileImage'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'profileImage': profileImage,
      'token': token,
    };
  }
}