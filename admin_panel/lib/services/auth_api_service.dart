import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/network/dio_error_mapper.dart';
import '../models/auth_response.dart';

/// Low-level HTTP calls for authentication endpoints.
///
/// Uses a standalone [Dio] instance without auth interceptors so login
/// and refresh requests never attach a stale Bearer token.
class AuthApiService {
  AuthApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throwApiExceptionFromResponse(e);
    }
  }

  Future<AuthResponse> refresh(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throwApiExceptionFromResponse(e);
    }
  }
}
