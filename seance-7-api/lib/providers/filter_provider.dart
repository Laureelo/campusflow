import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'tasks_provider.dart';

enum TaskFilter { all, todo, done, overdue }

class FilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.all;

  void select(TaskFilter filter) => state = filter;
}

final filterProvider = NotifierProvider<FilterNotifier, TaskFilter>(
  FilterNotifier.new,
);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);
  final now = DateTime.now();

  return tasks.whenData(
    (list) => switch (filter) {
      TaskFilter.all => list,
      TaskFilter.todo => list.where((task) => !task.done).toList(),
      TaskFilter.done => list.where((task) => task.done).toList(),
      TaskFilter.overdue => list.where((task) => task.isOverdue(now)).toList(),
    },
  );
});
