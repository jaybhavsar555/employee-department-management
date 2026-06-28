import 'package:dio/dio.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/models/page_response.dart';
import '../models/project.dart';

class ProjectRepository {
  ProjectRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<Project>> fetchPage({
    int page = 0,
    int size = 10,
    String sort = 'name,asc',
    int? departmentId,
    String? status,
    String? search,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          if (departmentId != null) 'departmentId': departmentId,
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PageResponse.fromJson(response.data!, Project.fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Project>> fetchAll({int size = 100}) async {
    final page = await fetchPage(size: size);
    return page.content;
  }

  Future<Project> create(ProjectRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects',
        data: request.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Project> update(int id, ProjectRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/projects/$id',
        data: request.toJson(),
      );
      return Project.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/projects/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(message: e.message ?? 'Request failed');
  }
}
