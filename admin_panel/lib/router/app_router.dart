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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isBootstrapping = authState.isLoading;
      final session = authState.valueOrNull;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isBootstrapping) return null;

      if (session == null && !isLoginRoute) return '/login';
      if (session != null && isLoginRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
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

/// Bridges Riverpod auth state changes into GoRouter's [refreshListenable].
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen<AsyncValue<AuthSession?>>(
      authStateProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
}
