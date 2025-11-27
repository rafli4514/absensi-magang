import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/activity.dart';
import '../models/api_response.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class LogbookService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  static Future<ApiResponse<List<Activity>>> getAllLogbook({
    int page = 1,
    int limit = 10,
    String? pesertaMagangId,
    String? tanggal,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (pesertaMagangId != null) 'pesertaMagangId': pesertaMagangId,
        if (tanggal != null) 'tanggal': tanggal,
      };

      final uri = Uri.parse(
        '$baseUrl/logbook',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<Activity> logbookList = (data['data'] as List)
            .map((item) => Activity.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          data: logbookList,
          message: data['message'],
          pagination: data['pagination'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve logbook',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve logbook: $e',
      );
    }
  }

  static Future<ApiResponse<Activity>> createLogbook({
    required String pesertaMagangId,
    required String tanggal,
    required String kegiatan,
    required String deskripsi,
    int? durasi,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/logbook'),
            headers: headers,
            body: jsonEncode({
              'pesertaMagangId': pesertaMagangId,
              'tanggal': tanggal,
              'kegiatan': kegiatan,
              'deskripsi': deskripsi,
              'durasi': durasi,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final activity = Activity.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: activity,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to create logbook',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to create logbook: $e',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/logbook/statistics'), headers: headers)
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return ApiResponse(
          success: true,
          data: Map<String, dynamic>.from(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve statistics',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve statistics: $e',
      );
    }
  }
}
