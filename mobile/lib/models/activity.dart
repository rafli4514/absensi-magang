import 'enum/activity_status.dart';
import 'enum/activity_type.dart';

class Activity {
  final String id;
  final String pesertaMagangId;
  final String tanggal;
  final String kegiatan;
  final String deskripsi;
  final int? durasi;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? pesertaMagang;

  Activity({
    required this.id,
    required this.pesertaMagangId,
    required this.tanggal,
    required this.kegiatan,
    required this.deskripsi,
    this.durasi,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pesertaMagang,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      pesertaMagangId: json['pesertaMagangId'] ?? '',
      tanggal: json['tanggal'] ?? '',
      kegiatan: json['kegiatan'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      durasi: json['durasi'],
      type: ActivityType.fromString(json['type'] ?? 'OTHER'),
      status: ActivityStatus.fromString(json['status'] ?? 'PENDING'),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      pesertaMagang: json['pesertaMagang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pesertaMagangId': pesertaMagangId,
      'tanggal': tanggal,
      'kegiatan': kegiatan,
      'deskripsi': deskripsi,
      'durasi': durasi,
      'type': type.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pesertaMagang': pesertaMagang,
    };
  }

  // Helper getters for UI
  String get title => kegiatan;
  String get description => deskripsi;
  DateTime get date => DateTime.parse(tanggal);
}
