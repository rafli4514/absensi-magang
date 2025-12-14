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
    int limit = 100,
    String? pesertaMagangId,
    String? tipe,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (pesertaMagangId != null && pesertaMagangId.isNotEmpty) 
          'pesertaMagangId': pesertaMagangId,
        if (tipe != null && tipe.isNotEmpty && tipe != 'Semua') 
          'tipe': tipe,
        if (status != null && status.isNotEmpty && status != 'Semua') 
          'status': status,
      };

      final uri = Uri.parse(
        '$baseUrl/absensi',
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
      
      final requestBody = {
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
      
      print('[ATTENDANCE SERVICE] Creating attendance: $requestBody');
      
      final response = await http
          .post(
            Uri.parse('$baseUrl/absensi'),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(timeout);

      print('[ATTENDANCE SERVICE] Response status: ${response.statusCode}');
      print('[ATTENDANCE SERVICE] Response body: ${response.body}');
      
      final responseBody = response.body;
      
      // Handle empty response body
      if (responseBody.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Server returned empty response',
          statusCode: response.statusCode,
        );
      }
      
      final data = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
        final attendance = Attendance.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: attendance,
          message: data['message'],
        );
      } else {
        // Get error message from response
        final errorMessage = data['message'] ?? 
            data['error'] ?? 
            'Failed to create attendance';
        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } on FormatException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid server response: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to create attendance: ${e.toString()}',
      );
    }
  }

  static Future<ApiResponse<Attendance>> getAttendanceById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/absensi/$id'), headers: headers)
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
        '$baseUrl/absensi',
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
