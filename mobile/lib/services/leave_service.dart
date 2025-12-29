import 'dart:convert';

import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class LeaveService {
  static const String baseUrl = AppConstants.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // --- 1. GET: Ambil daftar izin ---
  static Future<ApiResponse<List<Map<String, dynamic>>>> getLeaves({
    String? status,
    String? pesertaMagangId,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri =
          Uri.parse('$baseUrl/pengajuan-izin').replace(queryParameters: {
        'limit': '100', // Ambil cukup banyak data
        if (status != null) 'status': status,
        if (pesertaMagangId != null) 'pesertaMagangId': pesertaMagangId,
      });

      if (kDebugMode) {
        print('📡 [LeaveService] Fetching: $uri');
      }

      final response = await http.get(uri, headers: headers);

      if (kDebugMode) {
        print('📥 [LeaveService] Status: ${response.statusCode}');
        print('📥 [LeaveService] Body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse(
          success: true,
          message: data['message'],
          data: List<Map<String, dynamic>>.from(data['data']),
        );
      } else {
        return ApiResponse(
            success: false, message: data['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      print('❌ [LeaveService] Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // --- 2. POST: Buat Pengajuan Izin ---
  static Future<ApiResponse> createLeave({
    required String pesertaMagangId,
    required String tipe,
    required String alasan,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? dokumenPendukung,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'pesertaMagangId': pesertaMagangId,
        'tipe': tipe,
        'alasan': alasan,
        'tanggalMulai': tanggalMulai,
        'tanggalSelesai': tanggalSelesai,
        if (dokumenPendukung != null) 'dokumenPendukung': dokumenPendukung,
      });

      print('📤 [LeaveService] Sending: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/pengajuan-izin'),
        headers: headers,
        body: body,
      );

      print('📥 [LeaveService] Create Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: data['message'] ?? 'Pengajuan berhasil dikirim',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Gagal mengirim pengajuan',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // --- 3. APPROVE & REJECT ---
  static Future<bool> approveLeave(String id, {String catatan = ''}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pengajuan-izin/$id/approve');

      if (kDebugMode) {
        print('📡 [LeaveService] Approving: $url');
      }

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'catatan': catatan}),
      );

      if (kDebugMode) {
        print('📥 [LeaveService] Approve Status: ${response.statusCode}');
        print('📥 [LeaveService] Approve Body: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('❌ [LeaveService] Approve Error: $e');
      return false;
    }
  }

  static Future<bool> rejectLeave(String id, {String catatan = ''}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/pengajuan-izin/$id/reject');

      if (kDebugMode) {
        print('📡 [LeaveService] Rejecting: $url');
      }

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'catatan': catatan}),
      );

      if (kDebugMode) {
        print('📥 [LeaveService] Reject Status: ${response.statusCode}');
        print('📥 [LeaveService] Reject Body: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('❌ [LeaveService] Reject Error: $e');
      return false;
    }
  }
}
