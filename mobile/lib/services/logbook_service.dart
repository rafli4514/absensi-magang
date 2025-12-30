import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/logbook.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
// Import ApiService untuk akses singleton dan method multipart
import 'api_service.dart';

class LogbookService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  // Gunakan ApiService instance
  static final ApiService _apiService = ApiService();

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  static Future<ApiResponse<List<LogBook>>> getAllLogbook({
    int page = 1,
    int limit = 10,
    String? pesertaMagangId,
    String? tanggal,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (pesertaMagangId != null && pesertaMagangId.isNotEmpty)
          'pesertaMagangId': pesertaMagangId,
        if (tanggal != null && tanggal.isNotEmpty) 'tanggal': tanggal,
      };

      final uri =
          Uri.parse('$baseUrl/logbook').replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<LogBook> logbookList = (data['data'] as List)
            .map((item) => LogBook.fromJson(item))
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

  static Future<ApiResponse<LogBook>> createLogbook({
    required String pesertaMagangId,
    required String tanggal,
    required String kegiatan,
    required String deskripsi,
    String? durasi,
    String? type,
    String? status,
    File? foto, // Parameter file opsional
  }) async {
    try {
      // Jika ada foto, gunakan multipart request
      if (foto != null) {
        final fields = {
          'pesertaMagangId': pesertaMagangId,
          'tanggal': tanggal,
          'kegiatan': kegiatan,
          'deskripsi': deskripsi,
          if (durasi != null && durasi.isNotEmpty) 'durasi': durasi,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
        };

        // Baca bytes dari file
        final bytes = await foto.readAsBytes();
        final fileName = foto.path.split('/').last;

        return await _apiService.multipartPost<LogBook>(
          '/logbook', // Endpoint relative ke base URL ApiService
          fields,
          bytes,
          fileName,
          'foto', // Nama field file di backend (sesuaikan dengan backend Anda)
          fromJson: (data) => LogBook.fromJson(data),
        );
      }

      // Jika tidak ada foto, gunakan JSON post biasa
      else {
        final headers = await _getHeaders();
        final body = {
          'pesertaMagangId': pesertaMagangId,
          'tanggal': tanggal,
          'kegiatan': kegiatan,
          'deskripsi': deskripsi,
          if (durasi != null && durasi.isNotEmpty) 'durasi': durasi,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
        };

        final response = await http
            .post(
              Uri.parse('$baseUrl/logbook'),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(timeout);

        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final logbook = LogBook.fromJson(data['data']);
          return ApiResponse(
            success: true,
            data: logbook,
            message: data['message'],
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to create logbook',
          );
        }
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to create logbook: $e',
      );
    }
  }

  static Future<ApiResponse<LogBook>> updateLogbook({
    required String id,
    String? tanggal,
    String? kegiatan,
    String? deskripsi,
    String? durasi,
    String? type,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (tanggal != null) body['tanggal'] = tanggal;
      if (kegiatan != null) body['kegiatan'] = kegiatan;
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (durasi != null) body['durasi'] = durasi;
      if (type != null) body['type'] = type;
      if (status != null) body['status'] = status;

      final response = await http
          .put(
            Uri.parse('$baseUrl/logbook/$id'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final logbook = LogBook.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: logbook,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to update logbook',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to update logbook: $e',
      );
    }
  }

  static Future<ApiResponse<void>> deleteLogbook(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$baseUrl/logbook/$id'), headers: headers)
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return ApiResponse(
          success: true,
          message: data['message'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed to delete logbook',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to delete logbook: $e',
      );
    }
  }

  static Future<ApiResponse<LogBook>> getLogbookById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/logbook/$id'), headers: headers)
          .timeout(timeout);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final logbook = LogBook.fromJson(data['data']);
        return ApiResponse(
          success: true,
          data: logbook,
          message: data['message'],
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
