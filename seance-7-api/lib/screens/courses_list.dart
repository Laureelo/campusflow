import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/task.dart';
import '../providers/courses_provider.dart';
import '../providers/tasks_provider.dart';
import 'empty_state.dart';
import 'error_view.dart';

class CoursesList extends ConsumerWidget {
  const CoursesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];

    return courses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(coursesProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(icon: Icons.menu_book, title: 'No courses');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final course = list[index];
            final open = tasks
                .where((task) => task.courseId == course.id && !task.done)
                .length;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(course.name),
                subtitle: Text('${course.teacher} • $open to do'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/cours/${course.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
