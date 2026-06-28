import 'package:dio/dio.dart';

import '../../repositories/auth_repository.dart';

/// On HTTP 401, attempts a silent token refresh and retries the original request.
///
/// Skips auth endpoints and avoids infinite retry loops via [_retried] header.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor(this._authRepository, this._dio);

  final AuthRepository _authRepository;
  final Dio _dio;

  static const _retriedHeader = 'x-token-retried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    final newToken = await _authRepository.refreshAccessToken();
    if (newToken == null) {
      handler.next(err);
      return;
    }

    try {
      final response = await _retryRequest(err.requestOptions, newToken);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (err.requestOptions.path.contains('/auth/')) return false;
    if (err.requestOptions.headers[_retriedHeader] == true) return false;
    return true;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
        _retriedHeader: true,
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
