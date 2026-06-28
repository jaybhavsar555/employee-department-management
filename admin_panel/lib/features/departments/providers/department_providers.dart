import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/page_response.dart';
import '../../../core/providers/app_providers.dart';
import '../models/department.dart';
import '../repositories/department_repository.dart';

final departmentRepositoryProvider = Provider<DepartmentRepository>(
  (ref) => DepartmentRepository(ref.watch(dioProvider)),
);

class DepartmentListState {
  const DepartmentListState({
    this.isLoading = false,
    this.page,
    this.error,
    this.pageIndex = 0,
    this.search = '',
  });

  final bool isLoading;
  final PageResponse<Department>? page;
  final String? error;
  final int pageIndex;
  final String search;

  DepartmentListState copyWith({
    bool? isLoading,
    PageResponse<Department>? page,
    String? error,
    bool clearError = false,
    int? pageIndex,
    String? search,
  }) {
    return DepartmentListState(
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
      pageIndex: pageIndex ?? this.pageIndex,
      search: search ?? this.search,
    );
  }
}

class DepartmentListNotifier extends StateNotifier<DepartmentListState> {
  DepartmentListNotifier(this._repository) : super(const DepartmentListState());

  final DepartmentRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchPage(
        page: state.pageIndex,
        search: state.search.isEmpty ? null : state.search,
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

  Future<void> goToPage(int page) async {
    state = state.copyWith(pageIndex: page);
    await load();
  }

  Future<void> create(DepartmentRequest request) => _repository.create(request);

  Future<void> update(int id, DepartmentRequest request) =>
      _repository.update(id, request);

  Future<void> delete(int id) => _repository.delete(id);
}

final departmentListProvider =
    StateNotifierProvider<DepartmentListNotifier, DepartmentListState>((ref) {
  return DepartmentListNotifier(ref.watch(departmentRepositoryProvider));
});

/// For dropdowns in employee/project forms.
final departmentOptionsProvider = FutureProvider<List<Department>>((ref) {
  return ref.watch(departmentRepositoryProvider).fetchAll();
});
