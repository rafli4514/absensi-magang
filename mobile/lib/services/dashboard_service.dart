import '../models/api_response.dart';
import '../models/performance_stats.dart';
import 'api_service.dart';

class DashboardService {
  static final ApiService _apiService = ApiService();

  /// Get current month performance for a peserta magang
  static Future<ApiResponse<PerformanceStats>> getCurrentMonthPerformance({
    required String pesertaMagangId,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/dashboard/current-month-performance?pesertaMagangId=$pesertaMagangId',
        (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final stats = PerformanceStats.fromJson(response.data!);
        return ApiResponse<PerformanceStats>(
          success: true,
          message: response.message,
          data: stats,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<PerformanceStats>(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse<PerformanceStats>(
        success: false,
        message: 'Failed to get current month performance: $e',
        statusCode: 500,
      );
    }
  }
}

