import 'package:dio/dio.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/models/page_response.dart';
import '../models/employee.dart';

/// Data layer — HTTP calls for employees. UI never uses Dio directly.
class EmployeeRepository {
  EmployeeRepository(this._dio);

  final Dio _dio;

  Future<PageResponse<Employee>> fetchPage({
    int page = 0,
    int size = 10,
    String sort = 'lastName,asc',
    int? departmentId,
    String? search,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/employees',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          if (departmentId != null) 'departmentId': departmentId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PageResponse.fromJson(response.data!, Employee.fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Employee> create(EmployeeRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/employees',
        data: request.toJson(),
      );
      return Employee.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Employee> update(int id, EmployeeRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/employees/$id',
        data: request.toJson(),
      );
      return Employee.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/employees/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(message: e.message ?? 'Request failed');
  }
}
