import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'data_providers.dart';

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() {
    return ref.watch(taskRepositoryProvider).getAll();
  }

  Future<void> add({
    required String title,
    required DateTime dueDate,
    required int courseId,
  }) async {
    final created = await ref
        .read(taskRepositoryProvider)
        .create(title: title, dueDate: dueDate, courseId: courseId);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> toggle(int id) async {
    final task = state.value?.where((task) => task.id == id).firstOrNull;
    if (task == null) return;
    await _setDone(id, !task.done);
  }

  Future<void> markDone(int id) => _setDone(id, true);

  Future<void> delete(int id) async {
    await ref.read(taskRepositoryProvider).delete(id);
    state = AsyncData([
      for (final task in state.value ?? const <Task>[])
        if (task.id != id) task,
    ]);
  }

  Future<void> _setDone(int id, bool done) async {
    final updated = await ref
        .read(taskRepositoryProvider)
        .setDone(id, done: done);
    state = AsyncData([
      for (final task in state.value ?? const <Task>[])
        task.id == id ? updated : task,
    ]);
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);
