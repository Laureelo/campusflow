import 'package:campusflow_api/core/api_exception.dart';
import 'package:campusflow_api/core/token_storage.dart';
import 'package:campusflow_api/providers/auth_provider.dart';
import 'package:campusflow_api/providers/tasks_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  test('is signed in when a token is already stored', () async {
    final container = testContainer(sampleRepository());
    addTearDown(container.dispose);

    expect(await container.read(authProvider.future), isTrue);
  });

  test('is signed out when no token is stored', () async {
    final container = testContainer(
      sampleRepository(),
      tokenStorage: MemoryTokenStorage(),
    );
    addTearDown(container.dispose);

    expect(await container.read(authProvider.future), isFalse);
  });

  test('signIn stores the token and signs in', () async {
    final storage = MemoryTokenStorage();
    final container = testContainer(sampleRepository(), tokenStorage: storage);
    addTearDown(container.dispose);
    await container.read(authProvider.future);

    await container
        .read(authProvider.notifier)
        .signIn(email: 'awa@campus.test', password: 'campus123');

    expect(await storage.read(), 'fake-token');
    expect(container.read(authProvider).value, isTrue);
  });

  test('a wrong password throws and stores nothing', () async {
    final storage = MemoryTokenStorage();
    final container = testContainer(sampleRepository(), tokenStorage: storage);
    addTearDown(container.dispose);
    await container.read(authProvider.future);

    await expectLater(
      container
          .read(authProvider.notifier)
          .signIn(email: 'awa@campus.test', password: 'wrong'),
      throwsA(isA<ApiException>()),
    );

    expect(await storage.read(), isNull);
    expect(container.read(authProvider).value, isFalse);
  });

  test('an expired session removes the token and empties the tasks', () async {
    final storage = signedInStorage();
    final container = testContainer(sampleRepository(), tokenStorage: storage);
    addTearDown(container.dispose);
    expect(await container.read(tasksProvider.future), hasLength(4));

    await container.read(authProvider.notifier).expireSession();

    expect(await storage.read(), isNull);
    expect(container.read(authProvider).value, isFalse);
    expect(await container.read(tasksProvider.future), isEmpty);
  });
}
