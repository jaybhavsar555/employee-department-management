import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/department.dart';
import '../../services/department_service.dart';
import '../../shared/widgets/common_widgets.dart';

/// CRUD page for departments — GET, POST, PUT, DELETE /departments
class DepartmentsPage extends ConsumerStatefulWidget {
  const DepartmentsPage({super.key});

  @override
  ConsumerState<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends ConsumerState<DepartmentsPage> {
  List<Department>? _departments;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Fetches all departments from backend
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final departments =
          await ref.read(departmentServiceProvider).getAll();
      if (!mounted) return;
      setState(() {
        _departments = departments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
      });
    }
  }

  /// Opens create/edit dialog — reloads table if user saved
  Future<void> _openForm({Department? department}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _DepartmentFormDialog(department: department),
    );
    if (saved == true) await _load();
  }

  /// DELETE /departments/{id} — only shown for ROLE_ADMIN
  Future<void> _delete(Department department) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete department',
      message: 'Delete "${department.name}"? This requires admin role.',
    );
    if (confirmed != true) return;

    try {
      await ref.read(departmentServiceProvider).delete(department.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${department.name}')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth to show delete button only for admin
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;

    return Scaffold(
      body: _loading
          ? const LoadingView()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Departments',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => _openForm(), // Create new
                            icon: const Icon(Icons.add),
                            label: const Text('Add department'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Card(
                          child: _departments!.isEmpty
                              ? const Center(child: Text('No departments found.'))
                              : SingleChildScrollView(
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Description')),
                                      DataColumn(label: Text('Employees')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: _departments!.map((dept) {
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
                                                  tooltip: 'Edit',
                                                  icon: const Icon(Icons.edit_outlined),
                                                  onPressed: () =>
                                                      _openForm(department: dept),
                                                ),
                                                // Delete only visible for admin
                                                if (isAdmin)
                                                  IconButton(
                                                    tooltip: 'Delete',
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
                      ),
                    ],
                  ),
                ),
    );
  }
}

/// Popup form for create (department=null) or edit (department provided)
class _DepartmentFormDialog extends ConsumerStatefulWidget {
  const _DepartmentFormDialog({this.department});

  final Department? department;

  @override
  ConsumerState<_DepartmentFormDialog> createState() =>
      _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends ConsumerState<_DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields when editing
    _nameController = TextEditingController(text: widget.department?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.department?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final request = DepartmentRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      final service = ref.read(departmentServiceProvider);
      if (widget.department == null) {
        await service.create(request); // POST
      } else {
        await service.update(widget.department!.id, request); // PUT
      }
      if (!mounted) return;
      Navigator.pop(context, true); // Tell parent to reload list
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.department != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit department' : 'New department'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
