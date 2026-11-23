import 'package:dio/dio.dart';

import '../core/api_exception.dart';
import '../models/user.dart';

abstract interface class AuthRepository {
  Future<String> login({required String email, required String password});

  Future<User> currentUser();
}

class ApiAuthRepository implements AuthRepository {
  final Dio _dio;

  ApiAuthRepository(this._dio);

  @override
  Future<String> login({required String email, required String password}) {
    return guardApi(() async {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/login',
          data: {'email': email, 'password': password},
        );
        final token = response.data?['token'];
        if (token is! String) {
          throw const FormatException('Missing token');
        }
        return token;
      } on DioException catch (error) {
        if (error.response?.statusCode == 401) {
          throw const ApiException('Wrong email or password', statusCode: 401);
        }
        rethrow;
      }
    });
  }

  @override
  Future<User> currentUser() {
    return guardApi(() async {
      final response = await _dio.get<Map<String, dynamic>>('/me');
      return User.fromJson(response.data!);
    });
  }
}

class FakeAuthRepository implements AuthRepository {
  final User user;
  final String password;

  const FakeAuthRepository({required this.user, this.password = 'campus123'});

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (email != user.email || password != this.password) {
      throw const ApiException('Wrong email or password', statusCode: 401);
    }
    return 'fake-token';
  }

  @override
  Future<User> currentUser() async => user;
}
