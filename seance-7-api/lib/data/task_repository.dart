import '../models/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getAll();

  Future<Task> create({
    required String title,
    required DateTime dueDate,
    required int courseId,
  });

  Future<Task> setDone(int id, {required bool done});

  Future<void> delete(int id);
}
