import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/dio_client.dart';
import '../network/token_storage.dart';
import '../../repositories/auth_repository.dart';
import '../../services/auth_api_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final dioProvider = Provider<Dio>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return DioClient(authRepository).create();
});
