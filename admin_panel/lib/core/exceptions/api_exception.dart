// Typed error matching Spring Boot error JSON: { message, status, path }
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.path,
  });

  final String message; // Human-readable error from backend
  final int? statusCode; // HTTP code: 400, 401, 404, 409, etc.
  final String? path; // API path that failed, e.g. /api/v1/departments/5

  @override
  String toString() => message; // Show message when converted to string
}
