import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/dashboard.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(dioProvider)),
);

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.stats,
    this.activity = const [],
    this.error,
  });

  final bool isLoading;
  final DashboardStats? stats;
  final List<ActivityItem> activity;
  final String? error;

  DashboardState copyWith({
    bool? isLoading,
    DashboardStats? stats,
    List<ActivityItem>? activity,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      activity: activity ?? this.activity,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.fetchStats(),
        _repository.fetchActivity(),
      ]);
      state = state.copyWith(
        isLoading: false,
        stats: results[0] as DashboardStats,
        activity: results[1] as List<ActivityItem>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});
