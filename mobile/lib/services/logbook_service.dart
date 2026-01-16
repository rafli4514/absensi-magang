import 'dart:io';

import '../models/api_response.dart';
import '../models/logbook.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class LogbookService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<List<LogBook>>> getAllLogbook({
    int page = 1,
    int limit = 10, // Limit per request
    String? pesertaMagangId,
    String? tanggal,
    // Parameter Baru
    String? startDate,
    String? endDate,
  }) async {
    String query = '?page=$page&limit=$limit';

    if (pesertaMagangId != null) query += '&pesertaMagangId=$pesertaMagangId';
    if (tanggal != null) query += '&tanggal=$tanggal';

    // Tambahkan ke Query String
    if (startDate != null) query += '&startDate=$startDate';
    if (endDate != null) query += '&endDate=$endDate';

    return await _apiService.get(
      '${AppConstants.activitiesEndpoint}$query',
      (data) => (data as List).map((item) => LogBook.fromJson(item)).toList(),
    );
  }

  static Future<ApiResponse<LogBook>> createLogbook({
    required String pesertaMagangId,
    required String tanggal,
    required String kegiatan,
    required String deskripsi,
    String? durasi,
    String? type,
    String? status,
    String? fotoKegiatan,
  }) async {
    final Map<String, dynamic> fields = {
      'pesertaMagangId': pesertaMagangId,
      'tanggal': tanggal,
      'kegiatan': kegiatan,
      'deskripsi': deskripsi,
      if (durasi != null) 'durasi': durasi,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (fotoKegiatan != null) 'fotoKegiatan': fotoKegiatan,
    };

    return await _apiService.post(
      AppConstants.activitiesEndpoint,
      fields,
      (data) => LogBook.fromJson(data),
    );
  }

  static Future<ApiResponse<LogBook>> updateLogbook({
    required String id,
    String? tanggal,
    String? kegiatan,
    String? deskripsi,
    String? durasi,
    String? type,
    String? status,
    String? fotoKegiatan,
  }) async {
    final body = <String, dynamic>{};
    if (tanggal != null) body['tanggal'] = tanggal;
    if (kegiatan != null) body['kegiatan'] = kegiatan;
    if (deskripsi != null) body['deskripsi'] = deskripsi;
    if (durasi != null) body['durasi'] = durasi;
    if (type != null) body['type'] = type;
    if (status != null) body['status'] = status;
    if (fotoKegiatan != null) body['fotoKegiatan'] = fotoKegiatan;

    return await _apiService.put(
      '${AppConstants.activitiesEndpoint}/$id',
      body,
      (data) => LogBook.fromJson(data),
    );
  }

  static Future<ApiResponse<void>> deleteLogbook(String id) async {
    return await _apiService.delete(
      '${AppConstants.activitiesEndpoint}/$id',
      null,
    );
  }
}
