import '../models/api_response.dart';
import 'api_service.dart';

class InternService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<List<Map<String, dynamic>>>> getAllInterns() async {
    return await _apiService.get(
      '/peserta-magang?limit=100',
      (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // --- [BARU] Create Peserta Magang (Admin) ---
  static Future<ApiResponse> createIntern({
    required String nama,
    required String username,
    required String password,
    required String divisi,
    required String instansi,
    required String nomorHp,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? idPesertaMagang, // NIM/NISN
    String? namaMentor,
  }) async {
    final body = {
      'nama': nama,
      'username': username,
      'password': password,
      'divisi': divisi,
      'instansi': instansi,
      'nomorHp': nomorHp,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      if (idPesertaMagang != null) 'id_peserta_magang': idPesertaMagang,
      if (namaMentor != null) 'namaMentor': namaMentor,
      'status': 'AKTIF',
    };

    return await _apiService.post(
      '/peserta-magang',
      body,
      null, // Tidak perlu return data detail
    );
  }

  // --- [BARU] Update Peserta Magang ---
  static Future<ApiResponse> updateIntern({
    required String id, // PK Peserta
    String? nama,
    String? username,
    String? divisi,
    String? instansi,
    String? nomorHp,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? idPesertaMagang,
    String? namaMentor,
  }) async {
    final body = {
      if (nama != null) 'nama': nama,
      if (username != null) 'username': username,
      if (divisi != null) 'divisi': divisi,
      if (instansi != null) 'instansi': instansi,
      if (nomorHp != null) 'nomorHp': nomorHp,
      if (tanggalMulai != null) 'tanggalMulai': tanggalMulai,
      if (tanggalSelesai != null) 'tanggalSelesai': tanggalSelesai,
      if (idPesertaMagang != null) 'id_peserta_magang': idPesertaMagang,
      if (namaMentor != null) 'namaMentor': namaMentor,
    };

    return await _apiService.put(
      '/peserta-magang/$id',
      body,
      null,
    );
  }

  static Future<bool> deleteIntern(String id) async {
    final response = await _apiService.delete('/peserta-magang/$id', null);
    return response.success;
  }
}
