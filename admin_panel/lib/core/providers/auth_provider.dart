import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/api_exception.dart';
import '../../models/auth_session.dart';
import '../../repositories/auth_repository.dart';
import 'app_providers.dart';

// Riverpod provider — UI widgets watch this to know if user is logged in
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthSession?>>((ref) {
  // Create AuthNotifier and inject AuthRepository (handles API + storage)
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Manages login / logout / session restore for the whole Flutter app.
/// State is AsyncValue so we can show loading, error, or logged-in user.
class AuthNotifier extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    // On app start, try to restore session from secure storage
    _restoreSession();
  }

  final AuthRepository _repository;

  /// Called automatically at startup — reads saved tokens from device storage.
  Future<void> _restoreSession() async {
    try {
      final session = await _repository.restoreSession();
      // session is null if no tokens saved (user must log in)
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Called from LoginPage when user taps Sign in.
  /// Returns error message string, or null on success.
  Future<String?> login(String username, String password) async {
    state = const AsyncValue.loading(); // Show loading spinner on login button
    try {
      final session = await _repository.login(username, password);
      state = AsyncValue.data(session); // Router sees session → redirect to dashboard
      return null; // null means success
    } on ApiException catch (e) {
      state = const AsyncValue.data(null); // Still not logged in
      return e.message; // Show this in SnackBar
    } catch (e) {
      state = const AsyncValue.data(null);
      return e.toString();
    }
  }

  /// Clears tokens from storage and updates state — router sends user to /login.
  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
