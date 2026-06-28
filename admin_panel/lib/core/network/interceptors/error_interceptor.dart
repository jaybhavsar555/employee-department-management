import 'package:dio/dio.dart';

import '../../exceptions/api_exception.dart';

/// Converts Spring Boot error JSON into [ApiException] for consistent UI handling.
/// Why: screens catch one exception type instead of parsing Dio responses everywhere.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.data is Map<String, dynamic>) {
      final data = err.response!.data as Map<String, dynamic>;
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: ApiException(
            message: data['message'] as String? ?? 'Request failed',
            statusCode: err.response?.statusCode,
            path: data['path'] as String?,
          ),
        ),
      );
      return;
    }
    handler.next(err);
  }
}
