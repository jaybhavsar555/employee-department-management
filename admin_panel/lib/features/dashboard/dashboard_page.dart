import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/department.dart';
import '../../models/employee.dart';
import '../../services/department_service.dart';
import '../../services/employee_service.dart';
import '../../shared/widgets/common_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  List<Department>? _departments;
  PageResponse<Employee>? _employees;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final departments =
          await ref.read(departmentServiceProvider).getAll();
      final employees = await ref.read(employeeServiceProvider).getAll(size: 1);
      if (!mounted) return;
      setState(() {
        _departments = departments;
        _employees = employees;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView(message: 'Loading dashboard...');
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final totalEmployees = _employees?.totalElements ?? 0;
    final departmentCount = _departments?.length ?? 0;
    final avgPerDept = departmentCount == 0
        ? '0'
        : (totalEmployees / departmentCount).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your organization',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Departments',
                value: '$departmentCount',
                icon: Icons.business,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Employees',
                value: '$totalEmployees',
                icon: Icons.people,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Avg per Department',
                value: avgPerDept,
                icon: Icons.analytics_outlined,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Departments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (_departments!.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No departments yet. Create one from the Departments page.'),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _departments!.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final dept = _departments![index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(dept.name.characters.first.toUpperCase()),
                    ),
                    title: Text(dept.name),
                    subtitle: Text(dept.description ?? 'No description'),
                    trailing: Chip(label: Text('${dept.employeeCount} staff')),
                  );
                },
              ),
            ),
        ],
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
      width: 220,
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
