import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/attendance.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AttendanceService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  static Future<ApiResponse<List<Attendance>>> getAllAttendance({
    int page = 1,
    int limit = 10,
    String? pesertaMagangId,
    String? tipe,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (pesertaMagangId != null) 'pesertaMagangId': pesertaMagangId,
        if (tipe != null && tipe != 'Semua') 'tipe': tipe,
        if (status != null && status != 'Semua') 'status': status,
      };

      final uri = Uri.parse(
        '$baseUrl/attendance',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<Attendance> attendanceList = (data['data'] as List)
            .map((item) => Attendance.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          data: attendanceList,
          message: data['message'],
          pagination: data['pagination'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve attendance',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve attendance: $e',
      );
    }
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
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/attendance'),
            headers: headers,
            body: jsonEncode({
              'pesertaMagangId': pesertaMagangId,
              'tipe': tipe,
              'timestamp': timestamp.toIso8601String(),
              'lokasi': lokasi,
              'selfieUrl': selfieUrl,
              'qrCodeData': qrCodeData,
              'catatan': catatan,
              'ipAddress': ipAddress,
              'device': device,
            }),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final attendance = Attendance.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: attendance,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to create attendance',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to create attendance: $e',
      );
    }
  }

  static Future<ApiResponse<Attendance>> getAttendanceById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/attendance/$id'), headers: headers)
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final attendance = Attendance.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: attendance,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve attendance',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve attendance: $e',
      );
    }
  }

  static Future<ApiResponse<List<Attendance>>> getTodayAttendance() async {
    try {
      final headers = await _getHeaders();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final uri = Uri.parse(
        '$baseUrl/attendance',
      ).replace(queryParameters: {'tanggal': today, 'limit': '50'});

      final response = await http.get(uri, headers: headers).timeout(timeout);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<Attendance> attendanceList = (data['data'] as List)
            .map((item) => Attendance.fromJson(item))
            .toList();

        return ApiResponse(
          success: true,
          data: attendanceList,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to retrieve today\'s attendance',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to retrieve today\'s attendance: $e',
      );
    }
  }
}
