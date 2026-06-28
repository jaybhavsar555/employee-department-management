import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/department.dart';
import '../../models/employee.dart';
import '../../services/department_service.dart';
import '../../services/employee_service.dart';
import '../../shared/widgets/common_widgets.dart';

class EmployeesPage extends ConsumerStatefulWidget {
  const EmployeesPage({super.key});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage> {
  PageResponse<Employee>? _page;
  List<Department> _departments = [];
  String? _error;
  bool _loading = true;

  int _currentPage = 0;
  int? _departmentFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments =
          await ref.read(departmentServiceProvider).getAll();
      if (!mounted) return;
      setState(() => _departments = departments);
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await ref.read(employeeServiceProvider).getAll(
            page: _currentPage,
            departmentId: _departmentFilter,
            search: _searchQuery.isEmpty ? null : _searchQuery,
          );
      if (!mounted) return;
      setState(() {
        _page = page;
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

  Future<void> _openForm({Employee? employee}) async {
    if (_departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a department first')),
      );
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        employee: employee,
        departments: _departments,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(Employee employee) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete employee',
      message: 'Delete ${employee.fullName}? This requires admin role.',
    );
    if (confirmed != true) return;

    try {
      await ref.read(employeeServiceProvider).delete(employee.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${employee.fullName}')),
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

  void _applySearch() {
    _currentPage = 0;
    _searchQuery = _searchController.text.trim();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authStateProvider).valueOrNull?.isAdmin ?? false;
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Employees',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add employee'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _currentPage = 0;
                          _load();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _applySearch(),
                  ),
                ),
                FilledButton.tonal(onPressed: _applySearch, child: const Text('Search')),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int?>(
                    value: _departmentFilter,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All departments')),
                      ..._departments.map(
                        (dept) => DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _departmentFilter = value;
                        _currentPage = 0;
                      });
                      _load();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Card(
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
                                      rows: _page!.content.map((employee) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(employee.fullName)),
                                            DataCell(Text(employee.email)),
                                            DataCell(
                                              Text(employee.departmentName ?? '—'),
                                            ),
                                            DataCell(
                                              Text(currency.format(employee.salary)),
                                            ),
                                            DataCell(Text(employee.hireDate)),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    tooltip: 'Edit',
                                                    icon: const Icon(Icons.edit_outlined),
                                                    onPressed: () =>
                                                        _openForm(employee: employee),
                                                  ),
                                                  if (isAdmin)
                                                    IconButton(
                                                      tooltip: 'Delete',
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
                              if (_page!.totalPages > 1)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _currentPage > 0
                                            ? () {
                                                _currentPage--;
                                                _load();
                                              }
                                            : null,
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      Text(
                                        'Page ${_currentPage + 1} of ${_page!.totalPages} '
                                        '(${_page!.totalElements} total)',
                                      ),
                                      IconButton(
                                        onPressed: _currentPage < _page!.totalPages - 1
                                            ? () {
                                                _currentPage++;
                                                _load();
                                              }
                                            : null,
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeFormDialog extends ConsumerStatefulWidget {
  const _EmployeeFormDialog({
    this.employee,
    required this.departments,
  });

  final Employee? employee;
  final List<Department> departments;

  @override
  ConsumerState<_EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _salaryController;
  late int _departmentId;
  late DateTime _hireDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _firstNameController = TextEditingController(text: employee?.firstName ?? '');
    _lastNameController = TextEditingController(text: employee?.lastName ?? '');
    _emailController = TextEditingController(text: employee?.email ?? '');
    _salaryController = TextEditingController(
      text: employee != null ? employee.salary.toString() : '',
    );
    _departmentId = employee?.departmentId ?? widget.departments.first.id;
    _hireDate = employee != null
        ? DateTime.parse(employee.hireDate)
        : DateTime.now();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _hireDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final salary = double.tryParse(_salaryController.text.trim());
    if (salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid salary')),
      );
      return;
    }

    setState(() => _saving = true);
    final request = EmployeeRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      salary: salary,
      hireDate: DateFormat('yyyy-MM-dd').format(_hireDate),
      departmentId: _departmentId,
    );

    try {
      final service = ref.read(employeeServiceProvider);
      if (widget.employee == null) {
        await service.create(request);
      } else {
        await service.update(widget.employee!.id, request);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
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
    final isEdit = widget.employee != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit employee' : 'New employee'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _departmentId,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: widget.departments
                      .map(
                        (dept) => DropdownMenuItem(
                          value: dept.id,
                          child: Text(dept.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _departmentId = value);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hire date'),
                  subtitle: Text(DateFormat.yMMMd().format(_hireDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ),
              ],
            ),
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
