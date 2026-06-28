import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.watch(dioProvider)),
);

class ProjectListState {
  const ProjectListState({
    this.isLoading = false,
    this.page,
    this.error,
    this.pageIndex = 0,
    this.search = '',
    this.departmentFilter,
    this.statusFilter,
  });

  final bool isLoading;
  final ProjectPage? page;
  final String? error;
  final int pageIndex;
  final String search;
  final int? departmentFilter;
  final ProjectStatus? statusFilter;

  ProjectListState copyWith({
    bool? isLoading,
    ProjectPage? page,
    String? error,
    bool clearError = false,
    int? pageIndex,
    String? search,
    int? departmentFilter,
    bool clearDepartmentFilter = false,
    ProjectStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return ProjectListState(
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
      pageIndex: pageIndex ?? this.pageIndex,
      search: search ?? this.search,
      departmentFilter:
          clearDepartmentFilter ? null : (departmentFilter ?? this.departmentFilter),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class ProjectListNotifier extends StateNotifier<ProjectListState> {
  ProjectListNotifier(this._repository) : super(const ProjectListState());

  final ProjectRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _repository.fetchPage(
        page: state.pageIndex,
        departmentId: state.departmentFilter,
        status: state.statusFilter?.apiValue,
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

  Future<void> setDepartmentFilter(int? id) async {
    state = state.copyWith(
      departmentFilter: id,
      clearDepartmentFilter: id == null,
      pageIndex: 0,
    );
    await load();
  }

  Future<void> setStatusFilter(ProjectStatus? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
      pageIndex: 0,
    );
    await load();
  }

  Future<void> goToPage(int page) async {
    state = state.copyWith(pageIndex: page);
    await load();
  }

  Future<void> create(ProjectRequest request) => _repository.create(request);

  Future<void> update(int id, ProjectRequest request) =>
      _repository.update(id, request);

  Future<void> delete(int id) => _repository.delete(id);
}

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, ProjectListState>((ref) {
  return ProjectListNotifier(ref.watch(projectRepositoryProvider));
});

final projectOptionsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).fetchAll();
});
