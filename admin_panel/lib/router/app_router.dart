import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_provider.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/departments/departments_page.dart';
import '../features/employees/employees_page.dart';
import '../models/auth_session.dart';
import '../shared/widgets/admin_shell.dart';

// Creates GoRouter and re-builds when authStateProvider changes
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard', // Default page (redirect will fix if not logged in)
    refreshListenable: _AuthRefreshListenable(ref), // Re-run redirect when auth changes
    redirect: (context, state) {
      final isBootstrapping = authState.isLoading; // Still checking saved tokens?
      final session = authState.valueOrNull; // null = not logged in
      final isLoginRoute = state.matchedLocation == '/login';

      if (isBootstrapping) return null; // Wait — don't redirect yet

      // Not logged in and trying to open protected page → send to login
      if (session == null && !isLoginRoute) return '/login';

      // Already logged in but on login page → go to dashboard
      if (session != null && isLoginRoute) return '/dashboard';

      return null; // No redirect needed
    },
    routes: [
      // Public route — no shell layout
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Protected routes — wrapped in AdminShell (sidebar + logout)
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => const DepartmentsPage(),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeesPage(),
          ),
        ],
      ),
    ],
  );
});

/// GoRouter doesn't know about Riverpod by default.
/// This class listens to authStateProvider and notifies GoRouter to re-check redirects.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen<AsyncValue<AuthSession?>>(
      authStateProvider,
      (_, _) => notifyListeners(), // Login or logout → router re-evaluates redirect
    );
  }

  final Ref _ref;
}
