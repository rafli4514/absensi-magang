class Attendance {
  final String id;
  final String pesertaMagangId;
  final String tipe;
  final DateTime timestamp;
  final Map<String, dynamic>? lokasi;
  final String? selfieUrl;
  final String? qrCodeData;
  final String status;
  final String? catatan;
  final String? ipAddress;
  final String? device;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? pesertaMagang;

  Attendance({
    required this.id,
    required this.pesertaMagangId,
    required this.tipe,
    required this.timestamp,
    this.lokasi,
    this.selfieUrl,
    this.qrCodeData,
    required this.status,
    this.catatan,
    this.ipAddress,
    this.device,
    required this.createdAt,
    required this.updatedAt,
    this.pesertaMagang,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      pesertaMagangId: json['pesertaMagangId'] ?? '',
      tipe: json['tipe'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      lokasi: json['lokasi'] != null
          ? Map<String, dynamic>.from(json['lokasi'])
          : null,
      selfieUrl: json['selfieUrl'],
      qrCodeData: json['qrCodeData'],
      status: json['status'] ?? '',
      catatan: json['catatan'],
      ipAddress: json['ipAddress'],
      device: json['device'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      pesertaMagang: json['pesertaMagang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pesertaMagangId': pesertaMagangId,
      'tipe': tipe,
      'timestamp': timestamp.toIso8601String(),
      'lokasi': lokasi,
      'selfieUrl': selfieUrl,
      'qrCodeData': qrCodeData,
      'status': status,
      'catatan': catatan,
      'ipAddress': ipAddress,
      'device': device,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pesertaMagang': pesertaMagang,
    };
  }
}
