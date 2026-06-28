import 'package:dio/dio.dart';

import '../../repositories/auth_repository.dart';

/// Dio interceptor — runs when a request FAILS.
/// If failure is 401 Unauthorized, tries to refresh token and retry once.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor(this._authRepository, this._dio);

  final AuthRepository _authRepository;
  final Dio _dio; // Same Dio instance — used to retry the failed request

  // Custom header so we only retry once (prevents infinite loop)
  static const _retriedHeader = 'x-token-retried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Not a 401, or already retried, or auth endpoint — pass error through
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    // Ask backend for new access token using refresh token
    final newToken = await _authRepository.refreshAccessToken();
    if (newToken == null) {
      handler.next(err); // Refresh failed — user must log in again
      return;
    }

    try {
      // Retry the original request with the new token
      final response = await _retryRequest(err.requestOptions, newToken);
      handler.resolve(response); // Tell Dio the retry succeeded
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) return false; // Only refresh on 401
    if (err.requestOptions.path.contains('/auth/')) return false; // Don't refresh on login fail
    if (err.requestOptions.headers[_retriedHeader] == true) return false; // Already retried
    return true;
  }

  /// Re-sends the same HTTP request but with updated Authorization header.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
        _retriedHeader: true, // Mark as retried
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
