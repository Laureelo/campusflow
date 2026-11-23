import 'package:campusflow_api/core/api_exception.dart';
import 'package:campusflow_api/providers/tasks_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  test('starts in loading then holds the tasks of the repository', () async {
    final container = testContainer(sampleRepository());
    addTearDown(container.dispose);

    expect(container.read(tasksProvider), isA<AsyncLoading<dynamic>>());

    final tasks = await container.read(tasksProvider.future);

    expect(tasks, hasLength(4));
  });

  test('a failing repository puts the provider in the error state', () async {
    final repository = sampleRepository()
      ..failure = const ApiException('Cannot reach the server');
    final container = testContainer(repository);
    addTearDown(container.dispose);

    await expectLater(
      container.read(tasksProvider.future),
      throwsA(isA<ApiException>()),
    );

    expect(container.read(tasksProvider).hasError, isTrue);
  });

  test('add appends the task created by the repository', () async {
    final container = testContainer(sampleRepository());
    addTearDown(container.dispose);
    final before = await container.read(tasksProvider.future);

    await container
        .read(tasksProvider.notifier)
        .add(
          title: 'Write the report',
          dueDate: DateTime(2026, 12, 1),
          courseId: 10,
        );

    final after = container.read(tasksProvider).requireValue;
    expect(after, hasLength(before.length + 1));
    expect(after.last.id, 5);
    expect(after.last.done, isFalse);
  });

  test('toggle flips only the chosen task and replaces the list', () async {
    final container = testContainer(sampleRepository());
    addTearDown(container.dispose);
    final before = await container.read(tasksProvider.future);

    await container.read(tasksProvider.notifier).toggle(1);

    final after = container.read(tasksProvider).requireValue;
    expect(identical(before, after), isFalse);
    expect(after.firstWhere((t) => t.id == 1).done, isTrue);
    expect(after.firstWhere((t) => t.id == 2).done, isFalse);
    expect(before.firstWhere((t) => t.id == 1).done, isFalse);
  });

  test('markDone keeps a done task done', () async {
    final container = testContainer(sampleRepository());
    addTearDown(container.dispose);
    await container.read(tasksProvider.future);

    await container.read(tasksProvider.notifier).markDone(4);

    final tasks = container.read(tasksProvider).requireValue;
    expect(tasks.firstWhere((t) => t.id == 4).done, isTrue);
  });

  test(
    'delete removes the task from the state and from the repository',
    () async {
      final repository = sampleRepository();
      final container = testContainer(repository);
      addTearDown(container.dispose);
      await container.read(tasksProvider.future);

      await container.read(tasksProvider.notifier).delete(3);

      final tasks = container.read(tasksProvider).requireValue;
      expect(tasks.map((t) => t.id), [1, 2, 4]);
      expect((await repository.getAll()).map((t) => t.id), [1, 2, 4]);
    },
  );

  test('a failed action throws and leaves the list untouched', () async {
    final repository = sampleRepository();
    final container = testContainer(repository);
    addTearDown(container.dispose);
    await container.read(tasksProvider.future);
    repository.failure = const ApiException('Cannot reach the server');

    await expectLater(
      container.read(tasksProvider.notifier).toggle(1),
      throwsA(isA<ApiException>()),
    );

    final tasks = container.read(tasksProvider).requireValue;
    expect(tasks.firstWhere((t) => t.id == 1).done, isFalse);
  });
}
