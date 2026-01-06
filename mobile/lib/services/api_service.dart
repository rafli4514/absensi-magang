import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/global_context.dart';
import '../utils/global_error_handler.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getString(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';

        // Update BaseURL dinamis jika berubah (misal dari mDNS)
        if (AppConstants.baseUrl.isNotEmpty &&
            options.baseUrl != AppConstants.baseUrl) {
          options.baseUrl = AppConstants.baseUrl;
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response> Function() requestFn,
    T Function(dynamic)? fromJson,
  ) async {
    try {
      final response = await requestFn();
      final data = response.data;

      bool success = false;
      String message = '';

      if (data is Map<String, dynamic>) {
        success = data['success'] ??
            (response.statusCode! >= 200 && response.statusCode! < 300);
        message = data['message'] ?? 'Request processed';
      }

      if (success) {
        return ApiResponse<T>(
          success: true,
          message: message,
          data: (data['data'] != null && fromJson != null)
              ? fromJson(data['data'])
              : null,
          statusCode: response.statusCode,
          pagination: data['pagination'],
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: message.isNotEmpty ? message : 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      String errorMsg = e.message ?? 'Connection error';
      if (e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      final errorRes = ApiResponse<T>(
        success: false,
        message: errorMsg,
        statusCode: e.response?.statusCode ?? 500,
      );

      if (GlobalContext.currentContext != null) {
        GlobalErrorHandler.handle(errorRes);
      }
      return errorRes;
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<T>> get<T>(
      String endpoint, T Function(dynamic)? fromJson) {
    return _request(() => _dio.get(endpoint), fromJson);
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, dynamic body, T Function(dynamic)? fromJson,
      {Map<String, dynamic>? queryParameters}) {
    return _request(
        () => _dio.post(endpoint, data: body, queryParameters: queryParameters),
        fromJson);
  }

  Future<ApiResponse<T>> put<T>(String endpoint, Map<String, dynamic> body,
      T Function(dynamic)? fromJson) {
    return _request(() => _dio.put(endpoint, data: body), fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
      String endpoint, T Function(dynamic)? fromJson) {
    return _request(() => _dio.delete(endpoint), fromJson);
  }

  Future<ApiResponse<T>> patch<T>(String endpoint, Map<String, dynamic> body,
      T Function(dynamic)? fromJson) {
    return _request(() => _dio.patch(endpoint, data: body), fromJson);
  }

  Future<ApiResponse<T>> multipartPost<T>(
    String endpoint,
    Map<String, dynamic> fields,
    List<int> fileBytes,
    String fileName,
    String fieldName, {
    T Function(dynamic)? fromJson,
  }) async {
    final formData = FormData.fromMap(fields);
    formData.files.add(MapEntry(
      fieldName,
      MultipartFile.fromBytes(fileBytes, filename: fileName),
    ));

    return _request(() => _dio.post(endpoint, data: formData), fromJson);
  }
}
