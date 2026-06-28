import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/providers/auth_provider.dart';
import '../../departments/models/department.dart';
import '../../departments/providers/department_providers.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/pagination_bar.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(employeeListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(employeeListProvider);
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;
    final deptAsync = ref.watch(departmentOptionsProvider);
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Employees', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => deptAsync.whenOrNull(
                    data: (depts) => _openForm(departments: depts),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add employee'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilters(listState, deptAsync.valueOrNull ?? []),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(listState, isAdmin, currency)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(EmployeeListState listState, List<Department> departments) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  ref.read(employeeListProvider.notifier).setSearch('');
                },
              ),
            ),
            onSubmitted: (v) => ref.read(employeeListProvider.notifier).setSearch(v.trim()),
          ),
        ),
        FilledButton.tonal(
          onPressed: () =>
              ref.read(employeeListProvider.notifier).setSearch(_searchController.text.trim()),
          child: const Text('Search'),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<int?>(
            value: listState.departmentFilter,
            decoration: const InputDecoration(labelText: 'Department'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All departments')),
              ...departments.map(
                (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
              ),
            ],
            onChanged: (v) => ref.read(employeeListProvider.notifier).setDepartmentFilter(v),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(EmployeeListState listState, bool isAdmin, NumberFormat currency) {
    if (listState.isLoading && listState.page == null) {
      return const LoadingView();
    }
    if (listState.error != null && listState.page == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(listState.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(employeeListProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final page = listState.page!;
    if (page.isEmpty) {
      return EmptyStateView(
        title: 'No employees found',
        subtitle: listState.search.isNotEmpty
            ? 'Try a different search term.'
            : 'Add your first employee to get started.',
        actionLabel: 'Add employee',
        onAction: () {
          final depts = ref.read(departmentOptionsProvider).valueOrNull;
          if (depts != null) _openForm(departments: depts);
        },
      );
    }

    return Card(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Salary')),
                    DataColumn(label: Text('Hire date')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: page.content.map((employee) {
                    return DataRow(
                      cells: [
                        DataCell(Text(employee.fullName)),
                        DataCell(Text(employee.email)),
                        DataCell(Text(employee.departmentName ?? '—')),
                        DataCell(Text(currency.format(employee.salary))),
                        DataCell(Text(employee.hireDate)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  final depts =
                                      ref.read(departmentOptionsProvider).valueOrNull ?? [];
                                  _openForm(employee: employee, departments: depts);
                                },
                              ),
                              if (isAdmin)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(employee),
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
          PaginationBar(
            currentPage: listState.pageIndex,
            totalPages: page.totalPages,
            totalElements: page.totalElements,
            onPrevious: listState.pageIndex > 0
                ? () => ref.read(employeeListProvider.notifier).goToPage(listState.pageIndex - 1)
                : null,
            onNext: listState.pageIndex < page.totalPages - 1
                ? () => ref.read(employeeListProvider.notifier).goToPage(listState.pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({Employee? employee, required List<Department> departments}) async {
    if (departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a department first')),
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EmployeeFormDialog(employee: employee, departments: departments),
    );
    if (saved == true) await ref.read(employeeListProvider.notifier).load();
  }

  Future<void> _delete(Employee employee) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete employee',
      message: 'Delete ${employee.fullName}?',
    );
    if (confirmed != true) return;
    try {
      await ref.read(employeeListProvider.notifier).delete(employee.id);
      await ref.read(employeeListProvider.notifier).load();
    } catch (e) {
      if (!mounted) return;
      _showError(e);
    }
  }

  void _showError(Object e) {
    final msg = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }
}

class _EmployeeFormDialog extends ConsumerStatefulWidget {
  const _EmployeeFormDialog({this.employee, required this.departments});

  final Employee? employee;
  final List<Department> departments;

  @override
  ConsumerState<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _salary;
  late int _departmentId;
  late DateTime _hireDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _firstName = TextEditingController(text: e?.firstName ?? '');
    _lastName = TextEditingController(text: e?.lastName ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _salary = TextEditingController(text: e?.salary.toString() ?? '');
    _departmentId = e?.departmentId ?? widget.departments.first.id;
    _hireDate = e != null ? DateTime.parse(e.hireDate) : DateTime.now();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _salary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final salary = double.tryParse(_salary.text.trim());
    if (salary == null || salary <= 0) return;

    setState(() => _saving = true);
    final request = EmployeeRequest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      salary: salary,
      hireDate: DateFormat('yyyy-MM-dd').format(_hireDate),
      departmentId: _departmentId,
    );

    try {
      final notifier = ref.read(employeeListProvider.notifier);
      if (widget.employee == null) {
        await notifier.create(request);
      } else {
        await notifier.update(widget.employee!.id, request);
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
      title: Text(widget.employee == null ? 'New employee' : 'Edit employee'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || !v.contains('@') ? 'Invalid' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salary,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hire date'),
                  subtitle: Text(DateFormat.yMMMd().format(_hireDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _hireDate,
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _hireDate = picked);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.employee == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
