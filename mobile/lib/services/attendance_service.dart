import '../models/api_response.dart';
import '../models/attendance.dart';
import '../utils/constants.dart';
import '../utils/indonesian_time.dart';
import 'api_service.dart';

class AttendanceService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<List<Attendance>>> getAllAttendance({
    int page = 1,
    int limit = 100,
    String? pesertaMagangId,
    String? tipe,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String query = '?page=$page&limit=$limit';
    if (pesertaMagangId != null && pesertaMagangId.isNotEmpty)
      query += '&pesertaMagangId=$pesertaMagangId';
    if (tipe != null && tipe.isNotEmpty && tipe != 'Semua')
      query += '&tipe=$tipe';
    if (status != null && status.isNotEmpty && status != 'Semua')
      query += '&status=$status';

    // Note: startDate & endDate logic can be added here if backend supports it

    return await _apiService.get(
      '${AppConstants.attendanceEndpoint}$query',
      (data) =>
          (data as List).map((item) => Attendance.fromJson(item)).toList(),
    );
  }

  static Future<ApiResponse<Attendance>> createAttendance({
    required String pesertaMagangId,
    required String tipe,
    required DateTime timestamp,
    required Map<String, dynamic> lokasi,
    String? selfieUrl,
    String? qrCodeData,
    String? catatan,
    String? ipAddress,
    String? device,
  }) async {
    final body = {
      'pesertaMagangId': pesertaMagangId,
      'tipe': tipe,
      'timestamp': timestamp.toIso8601String(),
      'lokasi': lokasi,
      'selfieUrl': selfieUrl,
      'qrCodeData': qrCodeData,
      'catatan': catatan,
      'ipAddress': ipAddress,
      'device': device,
    };

    return await _apiService.post(
      AppConstants.attendanceEndpoint,
      body,
      (data) => Attendance.fromJson(data),
    );
  }

  static Future<ApiResponse<Attendance>> getAttendanceById(String id) async {
    return await _apiService.get(
      '${AppConstants.attendanceEndpoint}/$id',
      (data) => Attendance.fromJson(data),
    );
  }

  static Future<ApiResponse<List<Attendance>>> getTodayAttendance() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await _apiService.get(
      '${AppConstants.attendanceEndpoint}?tanggal=$today&limit=50',
      (data) =>
          (data as List).map((item) => Attendance.fromJson(item)).toList(),
    );
  }

  static bool isClockOutTimeReached(String workEndTime) {
    if (workEndTime.isEmpty) return false;
    try {
      final now = IndonesianTime.now;
      final parts = workEndTime.split(':');
      if (parts.length != 2) return false;
      final endHour = int.parse(parts[0]);
      final endMinute = int.parse(parts[1]);
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, endMinute);
      return now.isAfter(endTime) || now.isAtSameMomentAs(endTime);
    } catch (e) {
      return false;
    }
  }
}
