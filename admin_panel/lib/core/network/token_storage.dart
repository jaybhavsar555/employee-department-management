import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Saves and reads JWT tokens securely on the device.
/// Interview: "We never store tokens in plain SharedPreferences."
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: StorageKeys.accessToken);

  Future<String?> readRefreshToken() => _storage.read(key: StorageKeys.refreshToken);

  Future<String?> readUsername() => _storage.read(key: StorageKeys.username);

  Future<String?> readRole() => _storage.read(key: StorageKeys.role);

  /// Called after login or refresh — saves everything at once
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String username,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
      _storage.write(key: StorageKeys.username, value: username),
      _storage.write(key: StorageKeys.role, value: role),
    ]);
  }

  /// Called on token refresh — only tokens change, user info stays same
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  /// Called on logout — removes all saved auth data
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.username),
      _storage.delete(key: StorageKeys.role),
    ]);
  }
}
