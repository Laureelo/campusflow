import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('The server is taking too long to answer');
      case DioExceptionType.connectionError:
        return const ApiException('Cannot reach the server');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return ApiException(
          'The server answered with error $code',
          statusCode: code,
        );
      default:
        return const ApiException('Something went wrong');
    }
  }

  @override
  String toString() => message;
}

Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw ApiException.fromDio(error);
  } on FormatException {
    throw const ApiException('The server sent data we cannot read');
  }
}
