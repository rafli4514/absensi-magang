import '../../models/user.dart';
import '../../models/api_response.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class AuthService {
  static Future<ApiResponse<User>> login(String email, String password) async {
    final response = await ApiService().post(
      AppConstants.loginEndpoint,
      {
        'email': email,
        'password': password,
      },
      (data) => User.fromJson(data),
    );
    return response;
  }

  static Future<ApiResponse<User>> register(
    String name, 
    String email, 
    String password, 
    String department
  ) async {
    final response = await ApiService().post(
      AppConstants.registerEndpoint,
      {
        'name': name,
        'email': email,
        'password': password,
        'department': department,
      },
      (data) => User.fromJson(data),
    );
    return response;
  }
}