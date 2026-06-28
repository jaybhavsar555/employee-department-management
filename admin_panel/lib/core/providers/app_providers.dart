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

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final dioProvider = Provider<Dio>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(authRepository),
    TokenRefreshInterceptor(authRepository, dio),
    InterceptorsWrapper(
      onError: (error, handler) {
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
