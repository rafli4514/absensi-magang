import '../models/api_response.dart';
import '../models/performance_stats.dart';
import 'api_service.dart';

class DashboardService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<PerformanceStats>> getCurrentMonthPerformance({
    required String pesertaMagangId,
  }) async {
    return await _apiService.get(
      '/dashboard/current-month-performance?pesertaMagangId=$pesertaMagangId',
      (json) => PerformanceStats.fromJson(json),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    return await _apiService.get(
      '/dashboard/stats',
      (json) => Map<String, dynamic>.from(json),
    );
  }
}
