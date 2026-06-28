import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../../repositories/auth_repository.dart';
import 'auth_interceptor.dart';
import 'token_refresh_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Central Dio factory — single place for base URL, timeouts, and interceptors.
class DioClient {
  DioClient(this._authRepository);

  final AuthRepository _authRepository;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(_authRepository),
      TokenRefreshInterceptor(_authRepository, dio),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
