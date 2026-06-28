import 'package:dio/dio.dart';

import '../../../core/exceptions/api_exception.dart';
import '../models/dashboard.dart';

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardStats> fetchStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/dashboard/stats');
      return DashboardStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<ActivityItem>> fetchActivity({int limit = 15}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/dashboard/activity',
        queryParameters: {'limit': limit},
      );
      return response.data!
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(message: e.message ?? 'Request failed');
  }
}
