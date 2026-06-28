import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_provider.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/departments/screens/departments_screen.dart';
import '../features/employees/screens/employees_screen.dart';
import '../features/projects/screens/projects_screen.dart';
import '../features/tasks/screens/tasks_screen.dart';
import '../models/auth_session.dart';
import '../shared/widgets/admin_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
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
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => const DepartmentsScreen(),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen<AsyncValue<AuthSession?>>(
      authStateProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
}
