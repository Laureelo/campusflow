import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/courses_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/run_action.dart';
import 'empty_state.dart';
import 'error_view.dart';
import 'task_card.dart';

class CourseTasksScreen extends ConsumerWidget {
  final int courseId;

  const CourseTasksScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final tasks = ref.watch(tasksProvider);
    final course = courses.value
        ?.where((course) => course.id == courseId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(course?.name ?? 'Course')),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (list) {
          if (courses.hasValue && course == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Course not found',
            );
          }

          final mine = list.where((task) => task.courseId == courseId).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (course != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 8),
                      Text(course.teacher),
                    ],
                  ),
                ),
              if (mine.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyState(
                    icon: Icons.task_alt,
                    title: 'No deadlines for this course',
                  ),
                )
              else
                for (final task in mine)
                  TaskCard(
                    task: task,
                    courseName: course?.name ?? 'Unknown course',
                    onTap: () => context.push('/taches/${task.id}'),
                    onToggle: () => runAction(
                      context,
                      () => ref.read(tasksProvider.notifier).toggle(task.id),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
