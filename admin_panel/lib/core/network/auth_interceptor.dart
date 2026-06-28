import 'package:dio/dio.dart';

import '../../repositories/auth_repository.dart';

/// Attaches `Authorization: Bearer <access_token>` to every outgoing request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authRepository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
