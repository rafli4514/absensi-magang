import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  // Get dashboard data
  static Future<ApiResponse<DashboardModel>> getDashboard() async {
    try {
      final response = await ApiService.get(ApiConfig.dashboard);

      if (response['success']) {
        final dashboard = DashboardModel.fromJson(response['data']);
        
        return ApiResponse<DashboardModel>(
          success: true,
          message: response['message'],
          data: dashboard,
        );
      } else {
        return ApiResponse<DashboardModel>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil data dashboard',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<DashboardModel>(
        success: false,
        message: 'Gagal mengambil data dashboard: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get daily stats
  static Future<ApiResponse<DashboardStats>> getDailyStats() async {
    try {
      final response = await ApiService.get(ApiConfig.dailyStats);

      if (response['success']) {
        final stats = DashboardStats.fromJson(response['data']);
        
        return ApiResponse<DashboardStats>(
          success: true,
          message: response['message'],
          data: stats,
        );
      } else {
        return ApiResponse<DashboardStats>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil statistik harian',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<DashboardStats>(
        success: false,
        message: 'Gagal mengambil statistik harian: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // Get today's schedule
  static Future<ApiResponse<List<ScheduleItem>>> getTodaySchedule() async {
    try {
      final response = await ApiService.get('${ApiConfig.dashboard}/schedule');

      if (response['success']) {
        final scheduleList = (response['data'] as List)
            .map((e) => ScheduleItem.fromJson(e))
            .toList();
        
        return ApiResponse<List<ScheduleItem>>(
          success: true,
          message: response['message'],
          data: scheduleList,
        );
      } else {
        return ApiResponse<List<ScheduleItem>>(
          success: false,
          message: response['message'] ?? 'Gagal mengambil jadwal hari ini',
          error: response['error'],
        );
      }
    } catch (e) {
      return ApiResponse<List<ScheduleItem>>(
        success: false,
        message: 'Gagal mengambil jadwal hari ini: ${e.toString()}',
        error: e.toString(),
      );
    }
  }
}

