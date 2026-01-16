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

  final String? profileId; // PK of Peserta/Pembimbing table

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
    this.namaMentor,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.profileId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safety check: pastikan json tidak null/kosong
    if (json.isEmpty) return User(id: '', username: '', role: 'user');

    final pesertaMagang = json['pesertaMagang'];
    final pembimbing = json['pembimbing'];

    // Helper untuk mengambil nilai aman
    String safeString(dynamic val) => val?.toString() ?? '';

    return User(
      id: safeString(json['id']),
      username: safeString(json['username']),
      nama: json['nama'] ?? 
            json['name'] ?? 
            pesertaMagang?['nama'] ?? 
            pembimbing?['nama'] ?? // Add Pembimbing Name Check
            'User',

      email: json['email'],

      // Handle Role (bisa string, bisa object, huruf besar/kecil)
      role: safeString(json['role']).toLowerCase().isEmpty
          ? 'peserta_magang'
          : safeString(json['role']).toLowerCase(),

      idPesertaMagang: json['idPesertaMagang'] ??
          pesertaMagang?['id_peserta_magang'] ??
          pesertaMagang?['idPesertaMagang'] ??
          pembimbing?['nip'], // Fallback NIP for Mentor?

      divisi: json['divisi'] ?? 
              pesertaMagang?['divisi'] ??
              pembimbing?['bidang'], // Mentor Bidang as Divisi

      instansi: json['instansi'] ?? pesertaMagang?['instansi'],

      nomorHp:
          json['nomorHp'] ?? pesertaMagang?['nomorHp'] ?? json['phoneNumber'],

      tanggalMulai: json['tanggalMulai'] ?? pesertaMagang?['tanggalMulai'],
      tanggalSelesai:
          json['tanggalSelesai'] ?? pesertaMagang?['tanggalSelesai'],
      avatar: json['avatar'] ?? pesertaMagang?['avatar'],
      namaMentor: json['namaMentor'] ?? pesertaMagang?['namaMentor'],

      // Handle boolean isActive dengan aman
      isActive: json['isActive'] == true || json['isActive'] == 'true',

      // Parsing tanggal dengan try-parse agar tidak error
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      token: json['token'],
      profileId: pesertaMagang?['id'] ?? pembimbing?['id'],
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
      if (namaMentor != null) 'namaMentor': namaMentor,
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (profileId != null) 'profileId': profileId,
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
  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrator';
  bool get isStudent =>
      role.toLowerCase() == 'student' || role.toLowerCase() == 'peserta_magang';
  bool get isPembimbing =>
      role.toLowerCase() == 'pembimbing_magang' || role.toLowerCase() == 'mentor';
}
