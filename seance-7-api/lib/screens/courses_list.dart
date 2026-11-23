import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/courses_provider.dart';
import 'error_view.dart';

class CoursesList extends ConsumerWidget {
  const CoursesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return courses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(coursesProvider),
      ),
      data: (list) => ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final course = list[index];

          return ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(course.name),
            subtitle: Text(course.teacher),
          );
        },
      ),
    );
  }
}
