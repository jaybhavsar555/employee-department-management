// Global app settings used across the frontend
class AppConstants {
  AppConstants._(); // Private constructor — this class is not instantiated

  // API URL — can be overridden at build time with --dart-define=API_BASE_URL=...
  // Local dev: http://localhost:8080/api/v1
  // Docker: /api/v1 (nginx proxies to backend)
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}
