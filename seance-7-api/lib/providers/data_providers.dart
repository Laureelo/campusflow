import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_task_repository.dart';
import '../data/course_repository.dart';
import '../data/task_repository.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => ApiCourseRepository(ref.watch(dioProvider)),
);
