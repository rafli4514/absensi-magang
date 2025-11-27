class User {
  final String id;
  final String username;
  final String? nama; // untuk peserta magang
  final String? email;
  final String role;
  final String? divisi;
  final String? instansi;
  final String? avatar;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;

  User({
    required this.id,
    required this.username,
    this.nama,
    this.email,
    required this.role,
    this.divisi,
    this.instansi,
    this.avatar,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('🔍 User.fromJson received: $json');

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      nama: json['nama'] ?? json['name'],
      email: json['email'],
      role: json['role']?.toLowerCase() ?? '',
      divisi: json['divisi'],
      instansi: json['instansi'],
      avatar: json['avatar'],
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (nama != null) 'nama': nama,
      if (email != null) 'email': email,
      'role': role,
      if (divisi != null) 'divisi': divisi,
      if (instansi != null) 'instansi': instansi,
      if (avatar != null) 'avatar': avatar,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper getter untuk mendapatkan nama yang benar
  String get displayName => nama ?? username;
  
  // Helper getters untuk backward compatibility
  String? get name => nama;
  String? get department => divisi ?? instansi;
  String? get position => role; // atau bisa diubah sesuai kebutuhan
}
