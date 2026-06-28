import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>(
  (ref) => EmployeeRepository(ref.watch(dioProvider)),
);

class EmployeeListState {
  const EmployeeListState({
    this.isLoading = false,
    this.page,
    this.error,
    this.pageIndex = 0,
    this.departmentFilter,
    this.search = '',
    this.sort = 'lastName,asc',
  });

  final bool isLoading;
  final EmployeePage? page;
  final String? error;
  final int pageIndex;
  final int? departmentFilter;
  final String search;
  final String sort;

  EmployeeListState copyWith({
    bool? isLoading,
    EmployeePage? page,
    String? error,
    bool clearError = false,
    int? pageIndex,
    int? departmentFilter,
    bool clearDepartmentFilter = false,
    String? search,
    String? sort,
  }) {
    return EmployeeListState(
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
      pageIndex: pageIndex ?? this.pageIndex,
      departmentFilter:
          clearDepartmentFilter ? null : (departmentFilter ?? this.departmentFilter),
      search: search ?? this.search,
      sort: sort ?? this.sort,
    );
  }
}

/// Presentation layer state — loading, error, pagination, search.
class EmployeeListNotifier extends StateNotifier<EmployeeListState> {
  EmployeeListNotifier(this._repository) : super(const EmployeeListState());

  final EmployeeRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchPage(
        page: state.pageIndex,
        departmentId: state.departmentFilter,
        search: state.search.isEmpty ? null : state.search,
        sort: state.sort,
      );
      state = state.copyWith(isLoading: false, page: page);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setSearch(String query) async {
    state = state.copyWith(search: query, pageIndex: 0);
    await load();
  }

  Future<void> setDepartmentFilter(int? departmentId) async {
    state = state.copyWith(
      departmentFilter: departmentId,
      clearDepartmentFilter: departmentId == null,
      pageIndex: 0,
    );
    await load();
  }

  Future<void> goToPage(int page) async {
    state = state.copyWith(pageIndex: page);
    await load();
  }

  Future<void> create(EmployeeRequest request) => _repository.create(request);

  Future<void> update(int id, EmployeeRequest request) =>
      _repository.update(id, request);

  Future<void> delete(int id) => _repository.delete(id);
}

final employeeListProvider =
    StateNotifierProvider<EmployeeListNotifier, EmployeeListState>((ref) {
  return EmployeeListNotifier(ref.watch(employeeRepositoryProvider));
});

final employeeOptionsProvider = FutureProvider<List<Employee>>((ref) async {
  final page = await ref.watch(employeeRepositoryProvider).fetchPage(size: 100);
  return page.content;
});
