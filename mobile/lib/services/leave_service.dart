import '../models/api_response.dart';
import 'api_service.dart';

class LeaveService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<List<Map<String, dynamic>>>> getLeaves({
    String? status,
    String? pesertaMagangId,
  }) async {
    String query = '?limit=100';
    if (status != null) query += '&status=$status';
    if (pesertaMagangId != null) query += '&pesertaMagangId=$pesertaMagangId';

    return await _apiService.get(
      '/pengajuan-izin$query',
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  static Future<ApiResponse> createLeave({
    required String pesertaMagangId,
    required String tipe,
    required String alasan,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    final body = {
      'pesertaMagangId': pesertaMagangId,
      'tipe': tipe,
      'alasan': alasan,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
    };

    return await _apiService.post(
      '/pengajuan-izin',
      body,
      null, // Return null data jika tidak butuh parsing detail
    );
  }

  static Future<bool> approveLeave(String id, {String catatan = ''}) async {
    final response = await _apiService.patch(
      '/pengajuan-izin/$id/approve',
      {'catatan': catatan},
      null,
    );
    return response.success;
  }

  static Future<bool> rejectLeave(String id, {String catatan = ''}) async {
    final response = await _apiService.patch(
      '/pengajuan-izin/$id/reject',
      {'catatan': catatan},
      null,
    );
    return response.success;
  }

  static Future<String?> getTodayLeaveStatus(String pesertaMagangId) async {
    final response = await getLeaves(
      pesertaMagangId: pesertaMagangId,
      status: 'DISETUJUI',
    );

    if (response.success && response.data != null) {
      final now = DateTime.now();
      final dateNow = DateTime(now.year, now.month, now.day);

      for (var leave in response.data!) {
        try {
          final start = DateTime.parse(leave['tanggalMulai']);
          final end = DateTime.parse(leave['tanggalSelesai']);

          final dateStart = DateTime(start.year, start.month, start.day);
          final dateEnd = DateTime(end.year, end.month, end.day);

          if ((dateNow.isAtSameMomentAs(dateStart) ||
                  dateNow.isAfter(dateStart)) &&
              (dateNow.isAtSameMomentAs(dateEnd) ||
                  dateNow.isBefore(dateEnd))) {
            return leave['tipe'];
          }
        } catch (_) {}
      }
    }
    return null;
  }
}
