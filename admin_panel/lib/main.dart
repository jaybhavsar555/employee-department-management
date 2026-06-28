import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

// App entry point — runs before any widget is shown
Future<void> main() async {
  // Required before using plugins (secure storage, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope = Riverpod container — all providers live inside this
    const ProviderScope(
      child: AdminPanelApp(),
    ),
  );
}

// Root widget — sets up theme and navigation
class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly create Dio (with JWT interceptors) when app starts
    ref.watch(dioProvider);
    // GoRouter reads authStateProvider to protect routes
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EMS Admin Panel',
      debugShowCheckedModeBanner: false, // Hide "DEBUG" banner in corner
      theme: AppTheme.light(), // Material 3 blue theme
      routerConfig: router, // GoRouter handles /login, /dashboard, etc.
    );
  }
}
