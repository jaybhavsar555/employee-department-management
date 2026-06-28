import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../exceptions/api_exception.dart';
import '../network/auth_interceptor.dart';
import '../network/token_refresh_interceptor.dart';
import '../network/token_storage.dart';
import '../../repositories/auth_repository.dart';
import '../../services/auth_api_service.dart';

// Secure storage plugin — encrypts data on device
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

// Wrapper around secure storage with our key names
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

// Separate Dio for login/refresh — no JWT header attached
final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

// Auth repository = API + storage combined
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

// Main HTTP client used by department and employee services
final dioProvider = Provider<Dio>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl, // e.g. http://localhost:8080/api/v1
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Chain of interceptors — runs on every request/response
  dio.interceptors.addAll([
    AuthInterceptor(authRepository), // 1. Attach JWT
    TokenRefreshInterceptor(authRepository, dio), // 2. Refresh on 401
    InterceptorsWrapper(
      onError: (error, handler) {
        // 3. Convert Spring Boot error JSON to ApiException
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException(
                message: data['message'] as String? ?? 'Request failed',
                statusCode: error.response?.statusCode,
                path: data['path'] as String?,
              ),
            ),
          );
          return;
        }
        handler.next(error);
      },
    ),
  ]);

  return dio;
});
