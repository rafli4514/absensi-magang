enum AttendanceStatus {
  present,
  late,
  absent,
  halfDay,
}

class AttendanceRecord {
  final String id;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }
}