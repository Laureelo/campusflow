import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const String _configuredUrl = String.fromEnvironment('API_URL');

String defaultBaseUrl() {
  if (_configuredUrl.isNotEmpty) return _configuredUrl;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

Dio buildDio({String? baseUrl}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl ?? defaultBaseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
}
