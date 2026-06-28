import 'package:dio/dio.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/models/page_response.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<TaskItem>> fetchPage({
    int page = 0,
    int size = 10,
    String sort = 'dueDate,asc',
    int? projectId,
    int? assigneeId,
    String? status,
    String? priority,
    String? search,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tasks',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          if (projectId != null) 'projectId': projectId,
          if (assigneeId != null) 'assigneeId': assigneeId,
          if (status != null) 'status': status,
          if (priority != null) 'priority': priority,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PageResponse.fromJson(response.data!, TaskItem.fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<TaskItem> create(TaskRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tasks',
        data: request.toJson(),
      );
      return TaskItem.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<TaskItem> update(int id, TaskRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/tasks/$id',
        data: request.toJson(),
      );
      return TaskItem.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/tasks/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(message: e.message ?? 'Request failed');
  }
}
