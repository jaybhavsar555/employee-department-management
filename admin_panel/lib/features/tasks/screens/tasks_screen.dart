import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/providers/auth_provider.dart';
import '../../employees/models/employee.dart';
import '../../employees/providers/employee_providers.dart';
import '../../projects/models/project.dart';
import '../../projects/providers/project_providers.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/pagination_bar.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(taskListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(taskListProvider);
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;
    final projects = ref.watch(projectOptionsProvider).valueOrNull ?? [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: projects.isEmpty ? null : () => _openForm(projects: projects),
                  icon: const Icon(Icons.add),
                  label: const Text('Add task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: listState.completionFilter == TaskCompletionFilter.all,
                  onSelected: (_) => ref
                      .read(taskListProvider.notifier)
                      .setCompletionFilter(TaskCompletionFilter.all),
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: listState.completionFilter == TaskCompletionFilter.pending,
                  onSelected: (_) => ref
                      .read(taskListProvider.notifier)
                      .setCompletionFilter(TaskCompletionFilter.pending),
                ),
                FilterChip(
                  label: const Text('Completed'),
                  selected: listState.completionFilter == TaskCompletionFilter.completed,
                  onSelected: (_) => ref
                      .read(taskListProvider.notifier)
                      .setCompletionFilter(TaskCompletionFilter.completed),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    value: listState.projectFilter,
                    decoration: const InputDecoration(labelText: 'Project'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All projects')),
                      ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                    ],
                    onChanged: (v) => ref.read(taskListProvider.notifier).setProjectFilter(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(listState, isAdmin, projects)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TaskListState listState, bool isAdmin, List<Project> projects) {
    if (listState.isLoading && listState.page == null) return const LoadingView();
    if (listState.error != null && listState.page == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(listState.error!),
            FilledButton(
              onPressed: () => ref.read(taskListProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final page = listState.page!;
    if (page.isEmpty) {
      return EmptyStateView(
        title: 'No tasks',
        subtitle: 'Create tasks and track pending vs completed status.',
        actionLabel: 'Add task',
        onAction: projects.isEmpty ? null : () => _openForm(projects: projects),
      );
    }

    return Card(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assignee')),
                  DataColumn(label: Text('Due')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: page.content.map((task) {
                  return DataRow(
                    cells: [
                      DataCell(Text(task.title)),
                      DataCell(Text(task.projectName ?? '—')),
                      DataCell(Chip(label: Text(task.status.label))),
                      DataCell(Text(task.assigneeName ?? 'Unassigned')),
                      DataCell(Text(task.dueDate ?? '—')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (task.status.isPending)
                              IconButton(
                                tooltip: 'Mark completed',
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () => _complete(task),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(task: task, projects: projects),
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(task),
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
                ? () => ref.read(taskListProvider.notifier).goToPage(listState.pageIndex - 1)
                : null,
            onNext: listState.pageIndex < page.totalPages - 1
                ? () => ref.read(taskListProvider.notifier).goToPage(listState.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _complete(TaskItem task) async {
    try {
      await ref.read(taskListProvider.notifier).markCompleted(task);
      await ref.read(taskListProvider.notifier).load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : e.toString())),
      );
    }
  }

  Future<void> _openForm({TaskItem? task, required List<Project> projects}) async {
    final employees = ref.read(employeeOptionsProvider).valueOrNull ?? [];
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _TaskFormDialog(task: task, projects: projects, employees: employees),
    );
    if (saved == true) await ref.read(taskListProvider.notifier).load();
  }

  Future<void> _delete(TaskItem task) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete task',
      message: 'Delete "${task.title}"?',
    );
    if (confirmed != true) return;
    try {
      await ref.read(taskListProvider.notifier).delete(task.id);
      await ref.read(taskListProvider.notifier).load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : e.toString())),
      );
    }
  }
}

class _TaskFormDialog extends ConsumerStatefulWidget {
  const _TaskFormDialog({
    this.task,
    required this.projects,
    required this.employees,
  });

  final TaskItem? task;
  final List<Project> projects;
  final List<Employee> employees;

  @override
  ConsumerState<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late int _projectId;
  int? _assigneeId;
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _projectId = t?.projectId ?? widget.projects.first.id;
    _assigneeId = t?.assigneeId;
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate != null ? DateTime.tryParse(t!.dueDate!) : null;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final request = TaskRequest(
      title: _title.text.trim(),
      description: _description.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : null,
      projectId: _projectId,
      assigneeId: _assigneeId,
    );
    try {
      final notifier = ref.read(taskListProvider.notifier);
      if (widget.task == null) {
        await notifier.create(request);
      } else {
        await notifier.update(widget.task!.id, request);
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
      title: Text(widget.task == null ? 'New task' : 'Edit task'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
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
                  value: _projectId,
                  decoration: const InputDecoration(labelText: 'Project'),
                  items: widget.projects
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _projectId = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _assigneeId,
                  decoration: const InputDecoration(labelText: 'Assignee'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Unassigned')),
                    ...widget.employees.map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.fullName)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _assigneeId = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(widget.task == null ? 'Create' : 'Save')),
      ],
    );
  }
}
