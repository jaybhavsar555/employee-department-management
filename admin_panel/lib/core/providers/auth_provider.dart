import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/api_exception.dart';
import '../../models/auth_session.dart';
import '../../repositories/auth_repository.dart';
import 'app_providers.dart';

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthSession?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Manages authentication state for the entire app.
///
/// Exposes [AsyncValue<AuthSession?>] so the router can show a loading state
/// during startup, redirect unauthenticated users, and react to logout.
class AuthNotifier extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    try {
      final session = await _repository.restoreSession();
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Returns an error message on failure, or `null` on success.
  Future<String?> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final session = await _repository.login(username, password);
      state = AsyncValue.data(session);
      return null;
    } on ApiException catch (e) {
      state = const AsyncValue.data(null);
      return e.message;
    } catch (e) {
      state = const AsyncValue.data(null);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
