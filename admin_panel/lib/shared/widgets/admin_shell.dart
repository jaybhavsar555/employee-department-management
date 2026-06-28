import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../models/auth_session.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavItem('/dashboard', Icons.dashboard_outlined, 'Dashboard'),
    _NavItem('/departments', Icons.business_outlined, 'Departments'),
    _NavItem('/employees', Icons.people_outline, 'Employees'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authStateProvider).valueOrNull;
    final location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1100,
                  selectedIndex: _selectedIndex(location),
                  onDestinationSelected: (index) =>
                      context.go(_destinations[index].path),
                  labelType: constraints.maxWidth >= 1100
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  leading: _buildHeader(context, session, compact: true),
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: IconButton(
                          tooltip: 'Sign out',
                          onPressed: () => ref.read(authStateProvider.notifier).logout(),
                          icon: const Icon(Icons.logout),
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('EMS Admin'),
            actions: [
              if (session != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Chip(
                    avatar: const Icon(Icons.person, size: 18),
                    label: Text(session.username),
                  ),
                ),
              IconButton(
                tooltip: 'Sign out',
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: _buildHeader(context, session, compact: false),
                ),
                for (final item in _destinations)
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    selected: location.startsWith(item.path),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item.path);
                    },
                  ),
              ],
            ),
          ),
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex(location),
            onDestinationSelected: (index) => context.go(_destinations[index].path),
            destinations: _destinations
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  int _selectedIndex(String location) {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) {
        return i;
      }
    }
    return 0;
  }

  Widget _buildHeader(BuildContext context, AuthSession? session, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.admin_panel_settings, size: compact ? 32 : 40),
        const SizedBox(height: 8),
        Text(
          'EMS Admin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (session != null) ...[
          const SizedBox(height: 4),
          Text(
            session.username,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            session.isAdmin ? 'Administrator' : 'User',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.label);

  final String path;
  final IconData icon;
  final String label;
}
