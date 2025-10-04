class AbsensiStatsModel {
  final int totalHari;
  final int totalHadir;
  final int totalIzin;
  final int totalTerlambat;
  final int totalAlpha;
  final double persentaseKehadiran;

  AbsensiStatsModel({
    required this.totalHari,
    required this.totalHadir,
    required this.totalIzin,
    required this.totalTerlambat,
    required this.totalAlpha,
    required this.persentaseKehadiran,
  });

  factory AbsensiStatsModel.fromJson(Map<String, dynamic> json) {
    return AbsensiStatsModel(
      totalHari: json['totalHari'] ?? json['total_hari'] ?? 0,
      totalHadir: json['totalHadir'] ?? json['total_hadir'] ?? 0,
      totalIzin: json['totalIzin'] ?? json['total_izin'] ?? 0,
      totalTerlambat: json['totalTerlambat'] ?? json['total_terlambat'] ?? 0,
      totalAlpha: json['totalAlpha'] ?? json['total_alpha'] ?? 0,
      persentaseKehadiran: (json['persentaseKehadiran'] ?? json['persentase_kehadiran'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHari': totalHari,
      'totalHadir': totalHadir,
      'totalIzin': totalIzin,
      'totalTerlambat': totalTerlambat,
      'totalAlpha': totalAlpha,
      'persentaseKehadiran': persentaseKehadiran,
    };
  }
}
