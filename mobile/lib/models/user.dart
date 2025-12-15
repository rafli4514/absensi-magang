// lib/models/user.dart
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
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;

  // Include peserta magang data for student role
  final List<dynamic>? absensi;
  final List<dynamic>? pengajuanIzin;

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
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.absensi,
    this.pengajuanIzin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // print('🔍 User.fromJson received: $json'); // Debugging

    // Handle nested pesertaMagang data from backend
    final pesertaMagang = json['pesertaMagang'];
    final absensi = pesertaMagang != null ? pesertaMagang['absensi'] : null;
    final pengajuanIzin = pesertaMagang != null
        ? pesertaMagang['pengajuanIzin']
        : null;

    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      nama: json['nama'] ?? json['name'] ?? pesertaMagang?['nama'],
      email: json['email'],
      // Pastikan role selalu lowercase agar konsisten
      role: (json['role']?.toLowerCase() ?? ''),
      idPesertaMagang: json['idPesertaMagang'] ?? pesertaMagang?['id_peserta_magang'] ?? pesertaMagang?['idPesertaMagang'],
      divisi: json['divisi'] ?? pesertaMagang?['divisi'],
      instansi: json['instansi'] ?? pesertaMagang?['instansi'],
      nomorHp:
          json['nomorHp'] ?? pesertaMagang?['nomorHp'] ?? json['phoneNumber'],
      tanggalMulai: json['tanggalMulai'] ?? pesertaMagang?['tanggalMulai'],
      tanggalSelesai:
          json['tanggalSelesai'] ?? pesertaMagang?['tanggalSelesai'],
      avatar: json['avatar'] ?? pesertaMagang?['avatar'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      token: json['token'],
      absensi: absensi is List ? absensi : null,
      pengajuanIzin: pengajuanIzin is List ? pengajuanIzin : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
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
      if (isActive != null) 'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
    
    // Include pesertaMagang data if available (from fromJson parsing)
    // This ensures pesertaMagang.id is available in storage
    return json;
  }

  // --- HELPER GETTERS ---

  // Getter untuk tampilan UI yang rapi (Title Case)
  // Contoh: 'peserta_magang' -> 'Peserta Magang'
  String get displayRole {
    if (role.isEmpty) return '-';
    return role
        .replaceAll('_', ' ') // Ganti underscore dengan spasi
        .toLowerCase() // Kecilkan semua huruf
        .split(' ') // Pisah per kata
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}' // Kapital huruf pertama
              : '',
        )
        .join(' '); // Gabung kembali
  }

  // Helper getter untuk mendapatkan nama yang benar
  String get displayName => nama ?? username;

  // Helper getters untuk backward compatibility
  String? get name => nama;
  String? get department => divisi ?? instansi;

  // Gunakan displayRole agar tampilan di UI rapi
  String? get position => displayRole;

  // Helper untuk mengecek role
  bool get isAdmin => role.toLowerCase() == 'admin';

  // PERBAIKAN DI SINI: Cek juga 'peserta_magang'
  bool get isStudent =>
      role.toLowerCase() == 'student' || role.toLowerCase() == 'peserta_magang';

  bool get isPembimbing => role.toLowerCase() == 'pembimbing_magang';
  bool get isActiveUser => isActive ?? true;
}