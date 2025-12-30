import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class InternService {
  static const String baseUrl = AppConstants.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Ambil Semua Peserta Magang (Real Data)
  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllInterns() async {
    try {
      final headers = await _getHeaders();
      // Mengambil 100 data terbaru
      final response = await http.get(
        Uri.parse('$baseUrl/peserta-magang?limit=100'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return ApiResponse(
          success: true,
          message: data['message'],
          // Casting data ke List<Map> agar mudah dipakai di UI tanpa model khusus dulu
          data: List<Map<String, dynamic>>.from(data['data']),
        );
      } else {
        return ApiResponse(
            success: false, message: data['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Hapus Peserta
  static Future<bool> deleteIntern(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/peserta-magang/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
