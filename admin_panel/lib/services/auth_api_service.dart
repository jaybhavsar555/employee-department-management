import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/network/dio_error_mapper.dart';
import '../models/auth_response.dart';

/// HTTP calls for /auth/login and /auth/refresh only.
/// Uses its own Dio — NOT the one with JWT interceptors.
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

  /// POST /auth/login — returns access + refresh tokens
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

  /// POST /auth/refresh — exchange refresh token for new token pair
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
