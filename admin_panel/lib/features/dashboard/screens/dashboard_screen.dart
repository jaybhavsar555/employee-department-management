import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/dashboard.dart';
import '../providers/dashboard_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/empty_state_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    if (state.stats == null) {
      if (state.error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(dashboardProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      return const LoadingView(message: 'Loading dashboard...');
    }

    final stats = state.stats!;
    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Enterprise overview',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Departments',
                  value: '${stats.departments}',
                  icon: Icons.business,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Employees',
                  value: '${stats.employees}',
                  icon: Icons.people,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Projects',
                  value: '${stats.projects}',
                  icon: Icons.folder_outlined,
                  color: Colors.deepPurple,
                ),
                _StatCard(
                  title: 'Tasks',
                  value: '${stats.tasks}',
                  icon: Icons.task_alt,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Pending Tasks',
                  value: '${stats.pendingTasks}',
                  icon: Icons.pending_actions,
                  color: Colors.amber.shade800,
                ),
                _StatCard(
                  title: 'Completed Tasks',
                  value: '${stats.completedTasks}',
                  icon: Icons.check_circle_outline,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Audit-style feed sorted by last update (discuss timestamps & pagination in interviews)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: state.activity.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyStateView(
                        title: 'No recent activity',
                        subtitle: 'Create employees, departments, projects, or tasks.',
                        icon: Icons.history,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.activity.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = state.activity[index];
                        return _ActivityTile(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatTimestamp(item.timestamp);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(item.icon, size: 20),
      ),
      title: Text(item.message),
      subtitle: Text(formatted),
      trailing: Text(
        item.type.replaceAll('_', ' '),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat.yMMMd().add_jm().format(dt.toLocal());
    } catch (_) {
      return iso;
    }
  }
}
