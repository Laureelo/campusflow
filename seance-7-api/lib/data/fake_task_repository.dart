import '../core/api_exception.dart';
import '../models/task.dart';
import 'task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  final Duration delay;
  ApiException? failure;
  int _nextId;

  FakeTaskRepository({List<Task> tasks = const [], this.delay = Duration.zero})
    : _tasks = [...tasks],
      _nextId = tasks.fold<int>(0, (max, t) => t.id > max ? t.id : max) + 1;

  Future<void> _simulateNetwork() async {
    await Future<void>.delayed(delay);
    final error = failure;
    if (error != null) throw error;
  }

  @override
  Future<List<Task>> getAll() async {
    await _simulateNetwork();
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task> create({
    required String title,
    required DateTime dueDate,
    required int courseId,
  }) async {
    await _simulateNetwork();
    final task = Task(
      id: _nextId++,
      title: title,
      dueDate: dueDate,
      courseId: courseId,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> setDone(int id, {required bool done}) async {
    await _simulateNetwork();
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw const ApiException(
        'The server answered with error 404',
        statusCode: 404,
      );
    }
    final updated = _tasks[index].copyWith(done: done);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(int id) async {
    await _simulateNetwork();
    final before = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    if (_tasks.length == before) {
      throw const ApiException(
        'The server answered with error 404',
        statusCode: 404,
      );
    }
  }
}
