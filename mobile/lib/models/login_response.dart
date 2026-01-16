import 'user.dart';

class LoginResponse {
  final User user;
  final String token;
  final String? refreshToken;
  final String expiresIn;

  LoginResponse({
    required this.user,
    required this.token,
    this.refreshToken,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'] ?? '24h',
    );
  }
}

