class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.path,
  });

  final String message;
  final int? statusCode;
  final String? path;

  @override
  String toString() => message;
}
