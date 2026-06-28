import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_error_mapper.dart';
import '../core/providers/app_providers.dart';
import '../models/department.dart';

// Riverpod provider — injects authenticated Dio into DepartmentService
final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService(ref.watch(dioProvider));
});

/// Calls backend /departments endpoints.
/// Dio automatically adds JWT via AuthInterceptor.
class DepartmentService {
  DepartmentService(this._dio);

  final Dio _dio;

  /// GET /departments — list all departments
  Future<List<Department>> getAll() async {
    try {
      final response = await _dio.get<List<dynamic>>('/departments');
      return response.data!
          .map((item) => Department.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// POST /departments — create new department
  Future<Department> create(DepartmentRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/departments',
        data: request.toJson(),
      );
      return Department.fromJson(response.data!);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// PUT /departments/{id} — update existing department
  Future<Department> update(int id, DepartmentRequest request) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/departments/$id',
        data: request.toJson(),
      );
      return Department.fromJson(response.data!);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// DELETE /departments/{id} — admin only on backend
  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/departments/$id');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
