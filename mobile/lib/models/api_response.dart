// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      statusCode: json['statusCode'],
      pagination: json['pagination'],
    );
  }

  Map<String, dynamic> toJson(T Function(dynamic) toJson) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJson(data!) : null,
      'statusCode': statusCode,
      'pagination': pagination,
    };
  }
}
