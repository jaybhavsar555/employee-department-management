import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(dioProvider)),
);

class TaskListState {
  const TaskListState({
    this.isLoading = false,
    this.page,
    this.error,
    this.pageIndex = 0,
    this.search = '',
    this.projectFilter,
    this.completionFilter = TaskCompletionFilter.all,
  });

  final bool isLoading;
  final TaskPage? page;
  final String? error;
  final int pageIndex;
  final String search;
  final int? projectFilter;
  final TaskCompletionFilter completionFilter;

  TaskListState copyWith({
    bool? isLoading,
    TaskPage? page,
    String? error,
    bool clearError = false,
    int? pageIndex,
    String? search,
    int? projectFilter,
    bool clearProjectFilter = false,
    TaskCompletionFilter? completionFilter,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
      pageIndex: pageIndex ?? this.pageIndex,
      search: search ?? this.search,
      projectFilter:
          clearProjectFilter ? null : (projectFilter ?? this.projectFilter),
      completionFilter: completionFilter ?? this.completionFilter,
    );
  }
}

class TaskListNotifier extends StateNotifier<TaskListState> {
  TaskListNotifier(this._repository) : super(const TaskListState());

  final TaskRepository _repository;

  String? _statusParam() {
    switch (state.completionFilter) {
      case TaskCompletionFilter.completed:
        return TaskStatus.done.apiValue;
      case TaskCompletionFilter.pending:
      case TaskCompletionFilter.all:
        return null;
    }
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      var page = await _repository.fetchPage(
        page: state.pageIndex,
        projectId: state.projectFilter,
        status: _statusParam(),
        search: state.search.isEmpty ? null : state.search,
      );

      if (state.completionFilter == TaskCompletionFilter.pending) {
        final pending = page.content.where((t) => t.status.isPending).toList();
        page = TaskPage(
          content: pending,
          totalElements: pending.length,
          totalPages: page.totalPages,
          size: page.size,
          number: page.number,
          first: page.first,
          last: page.last,
        );
      }

      state = state.copyWith(isLoading: false, page: page);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setSearch(String query) async {
    state = state.copyWith(search: query, pageIndex: 0);
    await load();
  }

  Future<void> setProjectFilter(int? id) async {
    state = state.copyWith(
      projectFilter: id,
      clearProjectFilter: id == null,
      pageIndex: 0,
    );
    await load();
  }

  Future<void> setCompletionFilter(TaskCompletionFilter filter) async {
    state = state.copyWith(completionFilter: filter, pageIndex: 0);
    await load();
  }

  Future<void> goToPage(int page) async {
    state = state.copyWith(pageIndex: page);
    await load();
  }

  Future<void> create(TaskRequest request) => _repository.create(request);

  Future<void> update(int id, TaskRequest request) =>
      _repository.update(id, request);

  Future<void> delete(int id) => _repository.delete(id);

  Future<void> markCompleted(TaskItem task) => _repository.update(
        task.id,
        TaskRequest(
          title: task.title,
          description: task.description,
          status: TaskStatus.done,
          priority: task.priority,
          dueDate: task.dueDate,
          projectId: task.projectId,
          assigneeId: task.assigneeId,
        ),
      );
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(ref.watch(taskRepositoryProvider));
});
