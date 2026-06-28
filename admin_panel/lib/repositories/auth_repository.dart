import '../core/exceptions/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/auth_response.dart';
import '../models/auth_session.dart';
import '../services/auth_api_service.dart';

/// Middle layer between UI and network/storage.
/// Interview point: UI never calls Dio directly — it goes through Repository.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final AuthApiService _api; // HTTP calls to /auth/login and /auth/refresh
  final TokenStorage _storage; // Secure storage for tokens on device

  String? _cachedAccessToken; // In-memory cache so we don't read storage every request

  /// App startup: load tokens from secure storage and rebuild session.
  Future<AuthSession?> restoreSession() async {
    final session = await _readStoredSession();
    if (session != null) return session;

    // Storage reads are async; login may finish while bootstrap reads are in flight.
    final retry = await _readStoredSession();
    if (retry != null) return retry;

    await _storage.clear();
    _cachedAccessToken = null;
    return null;
  }

  Future<AuthSession?> _readStoredSession() async {
    final accessToken = await _storage.readAccessToken();
    final refreshToken = await _storage.readRefreshToken();
    final username = await _storage.readUsername();
    final role = await _storage.readRole();

    if (accessToken == null ||
        refreshToken == null ||
        username == null ||
        role == null) {
      return null;
    }

    _cachedAccessToken = accessToken;
    return AuthSession(username: username, role: role);
  }

  /// Login: call API, save tokens, return session for UI.
  Future<AuthSession> login(String username, String password) async {
    final response = await _api.login(
      LoginRequest(username: username, password: password),
    );
    await _persistAuthResponse(response);
    return AuthSession(username: response.username, role: response.role);
  }

  /// Logout: clear memory cache and delete all tokens from secure storage.
  Future<void> logout() async {
    _cachedAccessToken = null;
    await _storage.clear();
  }

  /// Used by AuthInterceptor before each API call.
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.readAccessToken();
    return _cachedAccessToken;
  }

  /// When API returns 401, TokenRefreshInterceptor calls this.
  /// Returns new access token, or null if refresh failed → user must log in again.
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await logout();
      return null;
    }

    try {
      final response = await _api.refresh(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      await _persistAuthResponse(response); // Save new token pair
      return response.token;
    } on ApiException {
      await logout(); // Refresh token expired or invalid
      return null;
    }
  }

  /// Save both tokens + user info after login or refresh.
  Future<void> _persistAuthResponse(AuthResponse response) async {
    _cachedAccessToken = response.token;
    await _storage.saveSession(
      accessToken: response.token,
      refreshToken: response.refreshToken,
      username: response.username,
      role: response.role,
    );
  }
}
