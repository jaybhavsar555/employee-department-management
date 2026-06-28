import 'package:dio/dio.dart';

import '../../repositories/auth_repository.dart';

/// Dio interceptor — runs BEFORE every HTTP request.
/// Adds JWT to the Authorization header so backend knows who we are.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read access token from repository (memory or secure storage)
    final token = await _authRepository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      // Same format backend expects: Authorization: Bearer <token>
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options); // Continue sending the request
  }
}
