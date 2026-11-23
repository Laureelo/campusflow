import 'package:campusflow_api/core/api_exception.dart';
import 'package:campusflow_api/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_adapter.dart';

void main() {
  test('login posts the credentials and returns the token', () async {
    final adapter = FakeAdapter(
      (_) => FakeAdapter.json({
        'token': 'abc123',
        'user': {'id': 1},
      }),
    );
    final repository = ApiAuthRepository(dioWith(adapter));

    final token = await repository.login(
      email: 'awa@campus.test',
      password: 'campus123',
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/login');
    expect(request.data, {'email': 'awa@campus.test', 'password': 'campus123'});
    expect(token, 'abc123');
  });

  test('a 401 on login becomes a wrong password message', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({}, status: 401));
    final repository = ApiAuthRepository(dioWith(adapter));

    await expectLater(
      repository.login(email: 'awa@campus.test', password: 'wrong'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Wrong email or password',
        ),
      ),
    );
  });

  test('a login answer without a token is refused', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({'user': {}}));
    final repository = ApiAuthRepository(dioWith(adapter));

    await expectLater(
      repository.login(email: 'awa@campus.test', password: 'campus123'),
      throwsA(isA<ApiException>()),
    );
  });

  test('currentUser reads /me', () async {
    final adapter = FakeAdapter(
      (_) => FakeAdapter.json({
        'id': 1,
        'name': 'Awa',
        'age': 23,
        'email': 'awa@campus.test',
      }),
    );
    final repository = ApiAuthRepository(dioWith(adapter));

    final user = await repository.currentUser();

    expect(adapter.requests.single.path, '/me');
    expect(user.name, 'Awa');
  });
}
