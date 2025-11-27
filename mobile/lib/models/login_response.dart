import 'user.dart';

class LoginResponse {
  final User user;
  final String token;
  final String expiresIn;

  LoginResponse({
    required this.user,
    required this.token,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      expiresIn: json['expiresIn'] ?? '24h',
    );
  }
}
