import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../models/task.dart';
import '../providers/courses_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/run_action.dart';
import 'empty_state.dart';
import 'error_view.dart';
import 'task_card.dart';

const Map<TaskFilter, String> _filterLabels = {
  TaskFilter.all: 'All',
  TaskFilter.todo: 'To do',
  TaskFilter.done: 'Done',
  TaskFilter.overdue: 'Overdue',
};

class WeekSummary extends ConsumerWidget {
  const WeekSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider).value;
    if (tasks == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final dueSoon = tasks
        .where((task) => !task.done && task.dueDate.isBefore(weekEnd))
        .length;
    final overdue = tasks.where((task) => task.isOverdue(now)).length;

    final summary = dueSoon == 0
        ? 'Nothing due in the next 7 days'
        : '$dueSoon due in the next 7 days'
              '${overdue > 0 ? ' • $overdue overdue' : ''}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(filterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final filter in TaskFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_filterLabels[filter]!),
                selected: filter == selected,
                onSelected: (_) =>
                    ref.read(filterProvider.notifier).select(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class DeadlinesList extends ConsumerWidget {
  final ValueChanged<Task> onTaskTap;
  final int? selectedId;

  const DeadlinesList({super.key, required this.onTaskTap, this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];

    String courseName(int courseId) {
      return courses
              .where((course) => course.id == courseId)
              .map((course) => course.name)
              .firstOrNull ??
          'Unknown course';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WeekSummary(),
        const FilterBar(),
        Expanded(
          child: tasks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(tasksProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                final noTasksAtAll =
                    (ref.watch(tasksProvider).value ?? const <Task>[]).isEmpty;
                return noTasksAtAll
                    ? const EmptyState(
                        icon: Icons.event_available,
                        title: 'No deadlines yet',
                        message: 'Tap the + button to add your first one',
                      )
                    : const EmptyState(
                        icon: Icons.filter_list_off,
                        title: 'No tasks for this filter',
                      );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final task = list[index];

                  return TaskCard(
                    task: task,
                    courseName: courseName(task.courseId),
                    selected: task.id == selectedId,
                    onTap: () => onTaskTap(task),
                    onToggle: () => runAction(
                      context,
                      () => ref.read(tasksProvider.notifier).toggle(task.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
