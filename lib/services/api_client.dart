import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout:
            const Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request & Auth Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic baseUrl support
          options.baseUrl = AppConfig.baseUrl;

          final token = await AuthService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[API Request] ${options.method} -> ${options.uri}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
                '[API Response] [${response.statusCode}] <- ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            debugPrint(
                '[API Error] [${error.response?.statusCode}] ${error.requestOptions.uri} : ${error.message}');
          }

          // Handle 401 Unauthorized globally
          if (error.response?.statusCode == 401) {
            debugPrint(
                '[API Error] Unauthorized 401 received. Token may have expired.');
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Generic helper methods
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return _dio.patch(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return _dio.delete(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  String formatError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final msg = error.response?.data['message'];
        if (msg != null && msg.toString().isNotEmpty) {
          return msg.toString();
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet connection or server status.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Could not connect to backend server at ${AppConfig.baseUrl}. Ensure backend is running.';
      }
      return error.message ?? 'An unexpected network error occurred.';
    }
    return error.toString();
  }
}
