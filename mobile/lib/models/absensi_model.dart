class AbsensiModel {
  final int id;
  final int userId;
  final String tanggal;
  final String? jamMasuk;
  final String? jamKeluar;
  final String? lokasi;
  final String? keterangan;
  final String? status;
  final String? tipe;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AbsensiModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    this.lokasi,
    this.keterangan,
    this.status,
    this.tipe,
    this.createdAt,
    this.updatedAt,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      tanggal: json['tanggal'],
      jamMasuk: json['jamMasuk'] ?? json['jam_masuk'],
      jamKeluar: json['jamKeluar'] ?? json['jam_keluar'],
      lokasi: json['lokasi'],
      keterangan: json['keterangan'],
      status: json['status'],
      tipe: json['tipe'],
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
      'userId': userId,
      'tanggal': tanggal,
      'jamMasuk': jamMasuk,
      'jamKeluar': jamKeluar,
      'lokasi': lokasi,
      'keterangan': keterangan,
      'status': status,
      'tipe': tipe,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

