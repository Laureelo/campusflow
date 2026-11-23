import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../data/api_task_repository.dart';
import '../data/course_repository.dart';
import '../data/task_repository.dart';

final dioProvider = Provider<Dio>((ref) => buildDio());

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => ApiCourseRepository(ref.watch(dioProvider)),
);
