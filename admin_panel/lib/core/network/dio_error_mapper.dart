import 'package:dio/dio.dart';

import '../exceptions/api_exception.dart';

// Converts any Dio/network error into our ApiException type
ApiException mapDioError(Object error) {
  if (error is DioException) {
    // Interceptor may have already wrapped the error
    if (error.error is ApiException) {
      return error.error as ApiException;
    }
    return ApiException(
      message: error.message ?? 'Network error',
      statusCode: error.response?.statusCode,
    );
  }
  return ApiException(message: error.toString());
}

// Reads Spring Boot error body and throws ApiException (never returns)
Never throwApiExceptionFromResponse(DioException error) {
  final response = error.response;
  if (response?.data is Map<String, dynamic>) {
    final data = response!.data as Map<String, dynamic>;
    throw ApiException(
      message: data['message'] as String? ?? 'Request failed',
      statusCode: response.statusCode,
      path: data['path'] as String?,
    );
  }
  throw ApiException(
    message: error.message ?? 'Network error',
    statusCode: response?.statusCode,
  );
}
