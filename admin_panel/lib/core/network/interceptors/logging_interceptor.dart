import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs HTTP method, path, and status in debug builds only.
/// Why: speeds up debugging without leaking tokens in production logs.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] --> ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] <-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] xx ${err.response?.statusCode} ${err.requestOptions.uri}');
    }
    handler.next(err);
  }
}
