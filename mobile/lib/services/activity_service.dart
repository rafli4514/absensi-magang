import '../models/api_response.dart';
import '../models/activity_log.dart';
import '../utils/app_config.dart';
import '../services/auth_service.dart';
import 'api_service.dart';
import 'download_service.dart';

/// Service for Activity Timeline and Export functionality
class ActivityService {
  static final ApiService _apiService = ApiService();

  /// Fetch Activity Timeline (Paginated)
  static Future<ApiResponse<List<ActivityLog>>> getTimeline({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    String query = '?page=$page&limit=$limit';
    if (userId != null) query += '&userId=$userId';

    return await _apiService.get(
      '${AppConfig.apiUrl}/activity$query',
      (data) {
        if (data is List) {
          return data.map((item) => ActivityLog.fromJson(item)).toList();
        } else if (data is Map && data['data'] is List) {
           // Handle paginated structure if backend wraps it
           return (data['data'] as List).map((item) => ActivityLog.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  /// Export data files (Logbook or Activity) in PDF/CSV format
  /// 
  /// [type]: 'logbook' or 'activity'
  /// [format]: 'pdf' or 'csv'
  /// 
  /// Uses platform-aware download service automatically
  static Future<void> exportData({
    required String type,
    required String format,
    String? startDate,
    String? endDate,
    String? pesertaId,
  }) async {
    // Build URL
    String url = '${AppConfig.apiUrl}/export/$type?format=$format';
    
    if (startDate != null && endDate != null) {
      url += '&startDate=$startDate&endDate=$endDate';
    }
    if (pesertaId != null) {
      url += '&pesertaMagangId=$pesertaId';
    }

    // Generate filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'Export_${type}_$timestamp.$format';
    
    // Build auth headers
    final headers = <String, String>{};
    if (AuthService.accessToken != null) {
      headers['Authorization'] = 'Bearer ${AuthService.accessToken}';
    }

    // Use platform-aware download service
    await downloadService.downloadFile(
      url: url,
      filename: filename,
      headers: headers,
    );
  }
}
