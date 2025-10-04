class UserModel {
  final String id;
  final String nama;
  final String username; 
  final String? email;
  final String? id_instansi;
  final String? jabatan;
  final String? divisi;
  final String? avatar;
  final String? role;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    this.email,
    this.id_instansi,
    this.jabatan,
    this.divisi,
    this.avatar,
    this.role,
    this.isActive,  // ✅ Ditambahkan isActive
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',  // ✅ Pastikan string
      nama: json['nama'] ?? json['name'] ?? '',
      username: json['username'] ?? '',  // ✅ Ditambahkan username
      email: json['email'] ?? '',
      id_instansi: json['id_instansi'] ?? json['nip'] ?? json['nim'],  // ✅ Support multiple field names
      jabatan: json['jabatan'],
      divisi: json['divisi'],
      avatar: json['avatar'],
      role: json['role'],
      isActive: json['isActive'],  // ✅ Ditambahkan isActive
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,  // ✅ Ditambahkan username
      'email': email,
      'id_instansi': id_instansi,  // ✅ Diubah dari nip ke id_instansi
      'jabatan': jabatan,
      'divisi': divisi,
      'avatar': avatar,
      'role': role,
      'isActive': isActive,  // ✅ Ditambahkan isActive
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? username,  // ✅ Ditambahkan username
    String? email,
    String? id_instansi,  // ✅ Diubah dari nip ke id_instansi
    String? jabatan,
    String? divisi,
    String? avatar,
    String? role,
    bool? isActive,  // ✅ Ditambahkan isActive
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,  // ✅ Ditambahkan username
      email: email ?? this.email,
      id_instansi: id_instansi ?? this.id_instansi,  // ✅ Diubah dari nip ke id_instansi
      jabatan: jabatan ?? this.jabatan,
      divisi: divisi ?? this.divisi,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,  // ✅ Ditambahkan isActive
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

