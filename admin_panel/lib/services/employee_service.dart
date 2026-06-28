import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_error_mapper.dart';
import '../core/providers/app_providers.dart';
import '../models/employee.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService(ref.watch(dioProvider));
});

/// Calls backend /employees endpoints with pagination and filters.
class EmployeeService {
  EmployeeService(this._dio);

  final Dio _dio;

  /// GET /employees?page=0&size=10&sort=lastName,asc&departmentId=1&search=john
  Future<PageResponse<Employee>> getAll({
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
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /employees
  Future<Employee> create(EmployeeRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/employees',
        data: request.toJson(),
      );
      return Employee.fromJson(response.data!);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// PUT /employees/{id}
  Future<Employee> update(int id, EmployeeRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/employees/$id',
        data: request.toJson(),
      );
      return Employee.fromJson(response.data!);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /employees/{id} — admin only on backend
  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/employees/$id');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
