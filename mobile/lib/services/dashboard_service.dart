import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/performance_stats.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class DashboardService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  /// Get monthly performance stats for a specific month
  static Future<ApiResponse<PerformanceStats>> getMonthlyPerformance({
    int? year,
    int? month,
    String? pesertaMagangId,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        if (year != null) 'year': year.toString(),
        if (month != null) 'month': month.toString(),
      };

      final uri = Uri.parse('$baseUrl/dashboard/monthly-stats')
          .replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final statsData = data['data'];
        
        // Calculate present days (masuk count) and total days
        final masuk = statsData['masuk'] ?? 0;
        final totalDays = statsData['periode']?['totalDays'] ?? 
                         _getTotalDaysInMonth(year ?? DateTime.now().year, 
                                            month ?? DateTime.now().month);
        
        // Filter by pesertaMagangId if provided
        // Since the API returns all stats, we need to get specific user's attendance
        final performance = PerformanceStats(
          presentDays: masuk,
          totalDays: totalDays,
          percentage: totalDays > 0 ? (masuk / totalDays * 100) : 0.0,
          targetAchieved: totalDays > 0 ? (masuk / totalDays * 100) >= 85 : false,
        );

        return ApiResponse(
          success: true,
          data: performance,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          data: PerformanceStats.empty(),
          message: data['message'] ?? 'Failed to retrieve performance stats',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: PerformanceStats.empty(),
        message: 'Failed to retrieve performance stats: $e',
      );
    }
  }

  /// Get current month performance stats for a specific user
  static Future<ApiResponse<PerformanceStats>> getCurrentMonthPerformance({
    required String pesertaMagangId,
  }) async {
    try {
      final now = DateTime.now();
      
      // Get all attendance for this month
      final attendanceResponse = await http.get(
        Uri.parse('$baseUrl/absensi').replace(queryParameters: {
          'pesertaMagangId': pesertaMagangId,
          'limit': '500',
        }),
        headers: await _getHeaders(),
      ).timeout(timeout);

      final attendanceData = jsonDecode(attendanceResponse.body);

      if (attendanceData['success'] == true && attendanceData['data'] != null) {
        final attendances = attendanceData['data'] as List;
        
        // Filter by current month
        final currentMonth = now.month;
        final currentYear = now.year;
        
        final monthAttendances = attendances.where((item) {
          final timestamp = DateTime.parse(item['timestamp'] ?? item['createdAt']);
          return timestamp.year == currentYear && timestamp.month == currentMonth;
        }).toList();

        // Count unique days with MASUK
        final masukDays = monthAttendances
            .where((item) => (item['tipe'] as String?)?.toUpperCase() == 'MASUK')
            .map((item) {
              final timestamp = DateTime.parse(item['timestamp'] ?? item['createdAt']);
              return '${timestamp.year}-${timestamp.month}-${timestamp.day}';
            })
            .toSet()
            .length;

        final totalDays = _getTotalDaysInMonth(currentYear, currentMonth);
        final percentage = totalDays > 0 ? (masukDays / totalDays * 100) : 0.0;

        return ApiResponse(
          success: true,
          data: PerformanceStats(
            presentDays: masukDays,
            totalDays: totalDays,
            percentage: percentage,
            targetAchieved: percentage >= 85,
          ),
          message: 'Performance stats retrieved successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          data: PerformanceStats.empty(),
          message: attendanceData['message'] ?? 'Failed to retrieve attendance',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        data: PerformanceStats.empty(),
        message: 'Failed to retrieve performance stats: $e',
      );
    }
  }

  /// Helper function to get total working days in a month
  static int _getTotalDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    int totalDays = 0;

    // Count working days (Monday-Friday)
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      final weekday = date.weekday; // 1 = Monday, 7 = Sunday
      if (weekday >= 1 && weekday <= 5) {
        totalDays++;
      }
    }

    return totalDays;
  }

  /// Get dashboard stats
  static Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/dashboard/stats'), headers: headers)
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return ApiResponse(
          success: true,
          data: data['data'],
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve dashboard stats',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve dashboard stats: $e',
      );
    }
  }
}



