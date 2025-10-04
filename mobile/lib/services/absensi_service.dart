import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/absensi_model.dart';
import '../models/absensi_stats_model.dart';
import 'api_service.dart';

class AbsensiService {
  // Check in
  static Future<ApiResponse<AbsensiModel>> checkIn({
    required String lokasi,
    String? keterangan,
    String? qrCode,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConfig.checkIn,
        {
          'lokasi': lokasi,
          if (keterangan != null) 'keterangan': keterangan,
          if (qrCode != null) 'qrCode': qrCode,
        },
      );

      if (response['success']) {
        final absensi = AbsensiModel.fromJson(response['data']);
        
        return ApiResponse<AbsensiModel>(
          success: true,
          message: response['message'] ?? 'Check-in berhasil',
          data: absensi,
        );
      } else {
        return ApiResponse<AbsensiModel>(
          success: false,
          message: response['message'] ?? 'Check-in gagal',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<AbsensiModel>(
        success: false,
        message: 'Check-in gagal: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Check out
  static Future<ApiResponse<AbsensiModel>> checkOut({
    required String lokasi,
    String? keterangan,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConfig.checkOut,
        {
          'lokasi': lokasi,
          if (keterangan != null) 'keterangan': keterangan,
        },
      );

      if (response['success']) {
        final absensi = AbsensiModel.fromJson(response['data']);
        
        return ApiResponse<AbsensiModel>(
          success: true,
          message: response['message'] ?? 'Check-out berhasil',
          data: absensi,
        );
      } else {
        return ApiResponse<AbsensiModel>(
          success: false,
          message: response['message'] ?? 'Check-out gagal',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<AbsensiModel>(
        success: false,
        message: 'Check-out gagal: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get absensi history
  static Future<ApiResponse<List<AbsensiModel>>> getHistory({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      String url = ApiConfig.absensiHistory;
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;
      
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await ApiService.get(url);

      if (response['success']) {
        final historyList = (response['data'] as List)
            .map((e) => AbsensiModel.fromJson(e))
            .toList();
        
        return ApiResponse<List<AbsensiModel>>(
          success: true,
          message: response['message'],
          data: historyList,
        );
      } else {
        return ApiResponse<List<AbsensiModel>>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil riwayat absensi',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<List<AbsensiModel>>(
        success: false,
        message: 'Gagal mengambil riwayat absensi: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get absensi statistics
  static Future<ApiResponse<AbsensiStatsModel>> getStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = ApiConfig.absensiStats;
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await ApiService.get(url);

      if (response['success']) {
        final stats = AbsensiStatsModel.fromJson(response['data']);
        
        return ApiResponse<AbsensiStatsModel>(
          success: true,
          message: response['message'],
          data: stats,
        );
      } else {
        return ApiResponse<AbsensiStatsModel>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil statistik absensi',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<AbsensiStatsModel>(
        success: false,
        message: 'Gagal mengambil statistik absensi: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get today's absensi
  static Future<ApiResponse<AbsensiModel>> getTodayAbsensi() async {
    try {
      final response = await ApiService.get('${ApiConfig.absensi}/today');

      if (response['success']) {
        final absensi = AbsensiModel.fromJson(response['data']);
        
        return ApiResponse<AbsensiModel>(
          success: true,
          message: response['message'],
          data: absensi,
        );
      } else {
        return ApiResponse<AbsensiModel>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil data absensi hari ini',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<AbsensiModel>(
        success: false,
        message: 'Gagal mengambil data absensi hari ini: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

}

