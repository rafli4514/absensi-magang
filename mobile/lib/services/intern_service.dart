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

  static Future<bool> deleteIntern(String id) async {
    final response = await _apiService.delete('/peserta-magang/$id', null);
    return response.success;
  }
}
