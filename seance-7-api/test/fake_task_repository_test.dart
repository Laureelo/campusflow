import 'package:campusflow_api/core/api_exception.dart';
import 'package:campusflow_api/data/fake_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sample_data.dart';

void main() {
  test('create gives the next free id', () async {
    final repository = FakeTaskRepository(tasks: buildSampleTasks());

    final task = await repository.create(
      title: 'New one',
      dueDate: DateTime(2026, 12, 1),
      courseId: 10,
    );

    expect(task.id, 5);
    expect((await repository.getAll()).length, 5);
  });

  test('setDone replaces the task with a copy', () async {
    final repository = FakeTaskRepository(tasks: buildSampleTasks());

    final updated = await repository.setDone(1, done: true);

    expect(updated.done, isTrue);
    final stored = (await repository.getAll()).firstWhere((t) => t.id == 1);
    expect(stored.done, isTrue);
  });

  test('delete removes the task and refuses an unknown id', () async {
    final repository = FakeTaskRepository(tasks: buildSampleTasks());

    await repository.delete(2);

    expect((await repository.getAll()).any((t) => t.id == 2), isFalse);
    expect(repository.delete(2), throwsA(isA<ApiException>()));
  });

  test('failure makes every call throw', () async {
    final repository = FakeTaskRepository(tasks: buildSampleTasks())
      ..failure = const ApiException('Cannot reach the server');

    expect(repository.getAll(), throwsA(isA<ApiException>()));
  });
}
