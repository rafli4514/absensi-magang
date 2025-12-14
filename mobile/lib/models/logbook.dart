import 'enum/activity_status.dart';
import 'enum/activity_type.dart';

class LogBook {
  final String id;
  final String pesertaMagangId;
  final String tanggal; // Format: YYYY-MM-DD
  final String kegiatan; // Kegiatan utama (sebelumnya title)
  final String deskripsi; // Detail keterangan (sebelumnya content)
  final String? durasi; // Durasi (optional)
  final ActivityType? type; // Type activity (untuk menggabungkan dengan Activity)
  final ActivityStatus? status; // Status activity
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Nested data from pesertaMagang relation
  final Map<String, dynamic>? pesertaMagang;

  LogBook({
    required this.id,
    required this.pesertaMagangId,
    required this.tanggal,
    required this.kegiatan,
    required this.deskripsi,
    this.durasi,
    this.type,
    this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pesertaMagang,
  });

  factory LogBook.fromJson(Map<String, dynamic> json) {
    return LogBook(
      id: json['id']?.toString() ?? '',
      pesertaMagangId: json['pesertaMagangId']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      kegiatan: json['kegiatan']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      durasi: json['durasi']?.toString(),
      type: json['type'] != null 
          ? ActivityType.fromString(json['type'].toString())
          : null,
      status: json['status'] != null
          ? ActivityStatus.fromString(json['status'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      pesertaMagang: json['pesertaMagang'] as Map<String, dynamic>?,
    );
  }

  // Helper untuk clone data saat edit
  LogBook copyWith({
    String? tanggal,
    String? kegiatan,
    String? deskripsi,
    String? durasi,
    ActivityType? type,
    ActivityStatus? status,
  }) {
    return LogBook(
      id: this.id,
      pesertaMagangId: this.pesertaMagangId,
      tanggal: tanggal ?? this.tanggal,
      kegiatan: kegiatan ?? this.kegiatan,
      deskripsi: deskripsi ?? this.deskripsi,
      durasi: durasi ?? this.durasi,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      pesertaMagang: this.pesertaMagang,
    );
  }

  // Legacy getters untuk backward compatibility (deprecated)
  @Deprecated('Use kegiatan instead')
  String get title => kegiatan;
  
  @Deprecated('Use deskripsi instead')
  String get content => deskripsi;
  
  @Deprecated('Location not in backend schema')
  String get location => '';
  
  @Deprecated('Mentor not in backend schema')
  String get mentorName => '';
}
