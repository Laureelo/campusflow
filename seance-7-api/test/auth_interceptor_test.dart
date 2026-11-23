import 'package:campusflow_api/core/auth_interceptor.dart';
import 'package:campusflow_api/core/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_adapter.dart';

void main() {
  late int unauthorizedCalls;

  setUp(() => unauthorizedCalls = 0);

  Dio buildClient(FakeAdapter adapter, TokenStorage storage) {
    final dio = dioWith(adapter);
    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        onUnauthorized: () => unauthorizedCalls++,
      ),
    );
    return dio;
  }

  test('adds the stored token to every request', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json([]));
    final dio = buildClient(adapter, MemoryTokenStorage('abc123'));

    await dio.get<dynamic>('/taches');
    await dio.get<dynamic>('/cours');

    expect(adapter.requests, hasLength(2));
    for (final request in adapter.requests) {
      expect(request.headers['Authorization'], 'Bearer abc123');
    }
  });

  test('sends no Authorization header when there is no token', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json([]));
    final dio = buildClient(adapter, MemoryTokenStorage());

    await dio.get<dynamic>('/taches');

    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test(
    'a 401 answer calls onUnauthorized and still fails the request',
    () async {
      final adapter = FakeAdapter((_) => FakeAdapter.json({}, status: 401));
      final dio = buildClient(adapter, MemoryTokenStorage('old'));

      await expectLater(
        dio.get<dynamic>('/taches'),
        throwsA(isA<DioException>()),
      );

      expect(unauthorizedCalls, 1);
    },
  );

  test('a 401 on /login is a wrong password, not an expired session', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({}, status: 401));
    final dio = buildClient(adapter, MemoryTokenStorage());

    await expectLater(
      dio.post<dynamic>('/login'),
      throwsA(isA<DioException>()),
    );

    expect(unauthorizedCalls, 0);
  });

  test('other errors do not touch the session', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({}, status: 500));
    final dio = buildClient(adapter, MemoryTokenStorage('abc123'));

    await expectLater(
      dio.get<dynamic>('/taches'),
      throwsA(isA<DioException>()),
    );

    expect(unauthorizedCalls, 0);
  });
}
