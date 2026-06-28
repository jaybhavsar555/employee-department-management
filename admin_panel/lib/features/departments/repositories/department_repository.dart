import 'package:dio/dio.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/models/page_response.dart';
import '../models/department.dart';

class DepartmentRepository {
  DepartmentRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<Department>> fetchPage({
    int page = 0,
    int size = 10,
    String sort = 'name,asc',
    String? search,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/departments',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PageResponse.fromJson(response.data!, Department.fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Loads up to [size] departments for dropdowns.
  Future<List<Department>> fetchAll({int size = 100}) async {
    final page = await fetchPage(size: size);
    return page.content;
  }

  Future<Department> create(DepartmentRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/departments',
        data: request.toJson(),
      );
      return Department.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Department> update(int id, DepartmentRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/departments/$id',
        data: request.toJson(),
      );
      return Department.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/departments/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(message: e.message ?? 'Request failed');
  }
}
