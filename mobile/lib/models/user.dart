class User {
  final String id;
  final String username;
  final String? nama;
  final String? email;
  final String role;
  final String? idPesertaMagang; // NISN/NIM
  final String? divisi;
  final String? instansi;
  final String? nomorHp;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? avatar;
  final String? namaMentor; // <--- Field Baru
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
    this.idPesertaMagang,
    this.divisi,
    this.instansi,
    this.nomorHp,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.avatar,
    this.namaMentor, // <--- Add to Constructor
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final pesertaMagang = json['pesertaMagang'];

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      nama: json['nama'] ?? json['name'] ?? pesertaMagang?['nama'],
      email: json['email'],
      role: (json['role']?.toLowerCase() ?? ''),
      idPesertaMagang: json['idPesertaMagang'] ??
          pesertaMagang?['id_peserta_magang'] ??
          pesertaMagang?['idPesertaMagang'],
      divisi: json['divisi'] ?? pesertaMagang?['divisi'],
      instansi: json['instansi'] ?? pesertaMagang?['instansi'],
      nomorHp:
          json['nomorHp'] ?? pesertaMagang?['nomorHp'] ?? json['phoneNumber'],
      tanggalMulai: json['tanggalMulai'] ?? pesertaMagang?['tanggalMulai'],
      tanggalSelesai:
          json['tanggalSelesai'] ?? pesertaMagang?['tanggalSelesai'],
      avatar: json['avatar'] ?? pesertaMagang?['avatar'],

      // --- MAPPING NAMA MENTOR ---
      namaMentor: json['namaMentor'] ?? pesertaMagang?['namaMentor'],

      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
      if (idPesertaMagang != null) 'idPesertaMagang': idPesertaMagang,
      if (divisi != null) 'divisi': divisi,
      if (instansi != null) 'instansi': instansi,
      if (nomorHp != null) 'nomorHp': nomorHp,
      if (tanggalMulai != null) 'tanggalMulai': tanggalMulai,
      if (tanggalSelesai != null) 'tanggalSelesai': tanggalSelesai,
      if (avatar != null) 'avatar': avatar,
      if (namaMentor != null) 'namaMentor': namaMentor, // <--- Add to JSON
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get displayRole {
    if (role.isEmpty) return '-';
    return role
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String get displayName => nama ?? username;
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStudent =>
      role.toLowerCase() == 'student' || role.toLowerCase() == 'peserta_magang';
  bool get isPembimbing => role.toLowerCase() == 'pembimbing_magang';
}
