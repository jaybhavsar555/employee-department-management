import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/providers/auth_provider.dart';
import '../../departments/models/department.dart';
import '../../departments/providers/department_providers.dart';
import '../../employees/models/employee.dart';
import '../../employees/providers/employee_providers.dart';
import '../models/project.dart';
import '../providers/project_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/pagination_bar.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(projectListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(projectListProvider);
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;
    final departments = ref.watch(departmentOptionsProvider).valueOrNull ?? [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Projects', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: departments.isEmpty
                      ? null
                      : () => _openForm(departments: departments),
                  icon: const Icon(Icons.add),
                  label: const Text('Add project'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search)),
                    onSubmitted: (v) => ref.read(projectListProvider.notifier).setSearch(v.trim()),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(projectListProvider.notifier).setSearch(_searchController.text.trim()),
                  child: const Text('Search'),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    value: listState.departmentFilter,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                    ],
                    onChanged: (v) => ref.read(projectListProvider.notifier).setDepartmentFilter(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(listState, isAdmin, departments)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ProjectListState listState, bool isAdmin, List<Department> departments) {
    if (listState.isLoading && listState.page == null) return const LoadingView();
    if (listState.error != null && listState.page == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(listState.error!),
            FilledButton(
              onPressed: () => ref.read(projectListProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final page = listState.page!;
    if (page.isEmpty) {
      return EmptyStateView(
        title: 'No projects',
        subtitle: 'Create a project under a department.',
        actionLabel: 'Add project',
        onAction: departments.isEmpty ? null : () => _openForm(departments: departments),
      );
    }

    return Card(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Lead')),
                  DataColumn(label: Text('Tasks')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: page.content.map((project) {
                  return DataRow(
                    cells: [
                      DataCell(Text(project.name)),
                      DataCell(Text(project.departmentName ?? '—')),
                      DataCell(Chip(label: Text(project.status.label))),
                      DataCell(Text(project.leadEmployeeName ?? '—')),
                      DataCell(Text('${project.taskCount}')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(
                                project: project,
                                departments: departments,
                              ),
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(project),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          PaginationBar(
            currentPage: listState.pageIndex,
            totalPages: page.totalPages,
            totalElements: page.totalElements,
            onPrevious: listState.pageIndex > 0
                ? () => ref.read(projectListProvider.notifier).goToPage(listState.pageIndex - 1)
                : null,
            onNext: listState.pageIndex < page.totalPages - 1
                ? () => ref.read(projectListProvider.notifier).goToPage(listState.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({Project? project, required List<Department> departments}) async {
    final employees = ref.read(employeeOptionsProvider).valueOrNull ?? [];
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ProjectFormDialog(
        project: project,
        departments: departments,
        employees: employees,
      ),
    );
    if (saved == true) await ref.read(projectListProvider.notifier).load();
  }

  Future<void> _delete(Project project) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete project',
      message: 'Delete "${project.name}"?',
    );
    if (confirmed != true) return;
    try {
      await ref.read(projectListProvider.notifier).delete(project.id);
      await ref.read(projectListProvider.notifier).load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : e.toString())),
      );
    }
  }
}

class _ProjectFormDialog extends ConsumerStatefulWidget {
  const _ProjectFormDialog({
    this.project,
    required this.departments,
    required this.employees,
  });

  final Project? project;
  final List<Department> departments;
  final List<Employee> employees;

  @override
  ConsumerState<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late int _departmentId;
  int? _leadId;
  ProjectStatus _status = ProjectStatus.planned;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _departmentId = p?.departmentId ?? widget.departments.first.id;
    _leadId = p?.leadEmployeeId;
    _status = p?.status ?? ProjectStatus.planned;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final request = ProjectRequest(
      name: _name.text.trim(),
      description: _description.text.trim(),
      status: _status,
      departmentId: _departmentId,
      leadEmployeeId: _leadId,
    );
    try {
      final notifier = ref.read(projectListProvider.notifier);
      if (widget.project == null) {
        await notifier.create(request);
      } else {
        await notifier.update(widget.project!.id, request);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'New project' : 'Edit project'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _departmentId,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: widget.departments
                      .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _departmentId = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProjectStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ProjectStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _leadId,
                  decoration: const InputDecoration(labelText: 'Project lead (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...widget.employees.map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.fullName)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _leadId = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(widget.project == null ? 'Create' : 'Save')),
      ],
    );
  }
}
