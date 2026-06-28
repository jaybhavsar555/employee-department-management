import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_error_mapper.dart';
import '../core/providers/app_providers.dart';
import '../models/department.dart';

final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService(ref.watch(dioProvider));
});

class DepartmentService {
  DepartmentService(this._dio);

  final Dio _dio;

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

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/departments/$id');
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
