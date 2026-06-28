import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/department.dart';
import '../providers/department_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/pagination_bar.dart';

class DepartmentsScreen extends ConsumerStatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  ConsumerState<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends ConsumerState<DepartmentsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(departmentListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(departmentListProvider);
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Departments', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add department'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (v) =>
                        ref.read(departmentListProvider.notifier).setSearch(v.trim()),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => ref
                      .read(departmentListProvider.notifier)
                      .setSearch(_searchController.text.trim()),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(listState, isAdmin)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DepartmentListState listState, bool isAdmin) {
    if (listState.isLoading && listState.page == null) return const LoadingView();
    if (listState.error != null && listState.page == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(listState.error!),
            FilledButton(
              onPressed: () => ref.read(departmentListProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final page = listState.page!;
    if (page.isEmpty) {
      return EmptyStateView(
        title: 'No departments',
        subtitle: 'Create a department to organize employees.',
        actionLabel: 'Add department',
        onAction: _openForm,
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
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Employees')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: page.content.map((dept) {
                  return DataRow(
                    cells: [
                      DataCell(Text(dept.name)),
                      DataCell(Text(dept.description ?? '—')),
                      DataCell(Text('${dept.employeeCount}')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(department: dept),
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(dept),
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
                ? () => ref.read(departmentListProvider.notifier).goToPage(listState.pageIndex - 1)
                : null,
            onNext: listState.pageIndex < page.totalPages - 1
                ? () => ref.read(departmentListProvider.notifier).goToPage(listState.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({Department? department}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _DepartmentFormDialog(department: department),
    );
    if (saved == true) await ref.read(departmentListProvider.notifier).load();
  }

  Future<void> _delete(Department department) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete department',
      message: 'Delete "${department.name}"?',
    );
    if (confirmed != true) return;
    try {
      await ref.read(departmentListProvider.notifier).delete(department.id);
      await ref.read(departmentListProvider.notifier).load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : e.toString())),
      );
    }
  }
}

class _DepartmentFormDialog extends ConsumerStatefulWidget {
  const _DepartmentFormDialog({this.department});

  final Department? department;

  @override
  ConsumerState<_DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends ConsumerState<_DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.department?.name ?? '');
    _description = TextEditingController(text: widget.department?.description ?? '');
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
    final request = DepartmentRequest(
      name: _name.text.trim(),
      description: _description.text.trim(),
    );
    try {
      final notifier = ref.read(departmentListProvider.notifier);
      if (widget.department == null) {
        await notifier.create(request);
      } else {
        await notifier.update(widget.department!.id, request);
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
      title: Text(widget.department == null ? 'New department' : 'Edit department'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
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
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(widget.department == null ? 'Create' : 'Save')),
      ],
    );
  }
}
