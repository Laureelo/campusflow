import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage storage;
  final void Function() onUnauthorized;

  AuthInterceptor({required this.storage, required this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isLogin = err.requestOptions.path == '/login';
    if (err.response?.statusCode == 401 && !isLogin) {
      onUnauthorized();
    }
    handler.next(err);
  }
}
