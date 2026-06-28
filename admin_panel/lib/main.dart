import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: AdminPanelApp(),
    ),
  );
}

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dioProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EMS Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
