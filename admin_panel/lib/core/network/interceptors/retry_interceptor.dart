import 'package:dio/dio.dart';

/// Retries idempotent GET requests once on timeout or connection errors.
/// Why: transient network blips should not fail the UI immediately.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 1});

  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retryCount = options.extra['retry_count'] as int? ?? 0;

    final shouldRetry = retryCount < maxRetries &&
        options.method.toUpperCase() == 'GET' &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError);

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    options.extra['retry_count'] = retryCount + 1;
    try {
      final response = await Dio().fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
