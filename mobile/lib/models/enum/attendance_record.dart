import 'attendance_status.dart';

class AttendanceRecord {
  final String id;
  final String userId;
  final String pesertaMagangId;
  final String tipe;
  final DateTime date;
  final DateTime timestamp;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final String? catatan;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final Map<String, dynamic>? lokasi;
  final String? selfieUrl;
  final String? qrCodeData;
  final String? ipAddress;
  final String? device;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? pesertaMagang;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.pesertaMagangId,
    required this.tipe,
    required this.date,
    required this.timestamp,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.catatan,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.lokasi,
    this.selfieUrl,
    this.qrCodeData,
    this.ipAddress,
    this.device,
    required this.createdAt,
    required this.updatedAt,
    this.pesertaMagang,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      pesertaMagangId: json['pesertaMagangId'] ?? '',
      tipe: json['tipe'] ?? '',
      date: DateTime.parse(json['date']),
      timestamp: DateTime.parse(json['timestamp']),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'])
          : null,
      status: AttendanceStatus.fromString(json['status'] ?? 'PENDING'),
      notes: json['notes'],
      catatan: json['catatan'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationAddress: json['locationAddress'],
      lokasi: json['lokasi'] != null
          ? Map<String, dynamic>.from(json['lokasi'])
          : null,
      selfieUrl: json['selfieUrl'],
      qrCodeData: json['qrCodeData'],
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
      'userId': userId,
      'pesertaMagangId': pesertaMagangId,
      'tipe': tipe,
      'date': date.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'catatan': catatan,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'lokasi': lokasi,
      'selfieUrl': selfieUrl,
      'qrCodeData': qrCodeData,
      'ipAddress': ipAddress,
      'device': device,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pesertaMagang': pesertaMagang,
    };
  }
}
