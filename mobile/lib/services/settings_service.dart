import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class SettingsService {
  static final ApiService _apiService = ApiService();

  static Future<ApiResponse<Map<String, dynamic>>> getSettings() async {
    return await _apiService.get(
      AppConstants.settingsEndpoint,
      (data) => Map<String, dynamic>.from(data),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> generateQRCode({
    String type = 'masuk',
  }) async {
    return await _apiService.post(
      '${AppConstants.settingsEndpoint}/qr/generate',
      {}, // Body kosong, parameter lewat query
      (data) => Map<String, dynamic>.from(data),
      queryParameters: {'type': type},
    );
  }
}
