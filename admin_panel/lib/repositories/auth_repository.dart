import '../core/exceptions/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/auth_response.dart';
import '../models/auth_session.dart';
import '../services/auth_api_service.dart';

/// Single entry point for authentication operations used by the UI layer.
///
/// Coordinates API calls and secure persistence. Other layers depend on this
/// class instead of talking to [AuthApiService] or [TokenStorage] directly.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final AuthApiService _api;
  final TokenStorage _storage;

  String? _cachedAccessToken;

  Future<AuthSession?> restoreSession() async {
    final accessToken = await _storage.readAccessToken();
    final refreshToken = await _storage.readRefreshToken();
    final username = await _storage.readUsername();
    final role = await _storage.readRole();

    if (accessToken == null ||
        refreshToken == null ||
        username == null ||
        role == null) {
      await _storage.clear();
      _cachedAccessToken = null;
      return null;
    }

    _cachedAccessToken = accessToken;
    return AuthSession(username: username, role: role);
  }

  Future<AuthSession> login(String username, String password) async {
    final response = await _api.login(
      LoginRequest(username: username, password: password),
    );
    await _persistAuthResponse(response);
    return AuthSession(username: response.username, role: response.role);
  }

  Future<void> logout() async {
    _cachedAccessToken = null;
    await _storage.clear();
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.readAccessToken();
    return _cachedAccessToken;
  }

  /// Called by [TokenRefreshInterceptor] when the API returns 401.
  ///
  /// Returns the new access token, or `null` if refresh failed (session dead).
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
      await _persistAuthResponse(response);
      return response.token;
    } on ApiException {
      await logout();
      return null;
    }
  }

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
