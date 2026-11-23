import 'package:campusflow_api/core/api_exception.dart';
import 'package:campusflow_api/data/api_task_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_adapter.dart';

const _taskJson = {
  'id': 3,
  'title': 'Prepare the networks quiz',
  'dueDate': '2026-12-03T10:00:00.000',
  'done': false,
  'courseId': 12,
};

void main() {
  test('getAll reads the tasks from /taches', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json([_taskJson]));
    final repository = ApiTaskRepository(dioWith(adapter));

    final tasks = await repository.getAll();

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/taches');
    expect(tasks.single.title, 'Prepare the networks quiz');
    expect(tasks.single.dueDate, DateTime(2026, 12, 3, 10));
  });

  test('create posts the new task and returns the one with an id', () async {
    final adapter = FakeAdapter(
      (_) => FakeAdapter.json(_taskJson, status: 201),
    );
    final repository = ApiTaskRepository(dioWith(adapter));

    final task = await repository.create(
      title: 'Prepare the networks quiz',
      dueDate: DateTime(2026, 12, 3, 10),
      courseId: 12,
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/taches');
    expect(request.data, {
      'title': 'Prepare the networks quiz',
      'dueDate': '2026-12-03T10:00:00.000',
      'done': false,
      'courseId': 12,
    });
    expect(task.id, 3);
  });

  test('setDone sends a PATCH with only the done field', () async {
    final adapter = FakeAdapter(
      (_) => FakeAdapter.json({..._taskJson, 'done': true}),
    );
    final repository = ApiTaskRepository(dioWith(adapter));

    final task = await repository.setDone(3, done: true);

    final request = adapter.requests.single;
    expect(request.method, 'PATCH');
    expect(request.path, '/taches/3');
    expect(request.data, {'done': true});
    expect(task.done, isTrue);
  });

  test('delete sends a DELETE on the task address', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({}));
    final repository = ApiTaskRepository(dioWith(adapter));

    await repository.delete(3);

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/taches/3');
  });

  test('a server error becomes an ApiException with its status code', () async {
    final adapter = FakeAdapter((_) => FakeAdapter.json({}, status: 500));
    final repository = ApiTaskRepository(dioWith(adapter));

    expect(
      repository.getAll(),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
      ),
    );
  });

  test('a network failure becomes an ApiException', () async {
    final adapter = FakeAdapter((options) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    });
    final repository = ApiTaskRepository(dioWith(adapter));

    expect(
      repository.getAll(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Cannot reach the server',
        ),
      ),
    );
  });

  test('a task with a missing field becomes an ApiException', () async {
    final adapter = FakeAdapter(
      (_) => FakeAdapter.json([
        {'id': 1},
      ]),
    );
    final repository = ApiTaskRepository(dioWith(adapter));

    expect(repository.getAll(), throwsA(isA<ApiException>()));
  });
}
