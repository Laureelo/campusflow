import 'package:campusflow_api/data/course_repository.dart';
import 'package:campusflow_api/data/fake_task_repository.dart';
import 'package:campusflow_api/main.dart';
import 'package:campusflow_api/providers/data_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'sample_data.dart';

FakeTaskRepository sampleRepository({Duration delay = Duration.zero}) {
  return FakeTaskRepository(tasks: buildSampleTasks(), delay: delay);
}

List<Override> testOverrides(FakeTaskRepository repository) {
  return [
    taskRepositoryProvider.overrideWithValue(repository),
    courseRepositoryProvider.overrideWithValue(
      const FakeCourseRepository(sampleCourses),
    ),
  ];
}

ProviderContainer testContainer(FakeTaskRepository repository) {
  return ProviderContainer(
    retry: (_, _) => null,
    overrides: testOverrides(repository),
  );
}

Widget testScope({required Widget child, FakeTaskRepository? repository}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: testOverrides(repository ?? sampleRepository()),
    child: child,
  );
}

Widget buildTestApp({FakeTaskRepository? repository}) {
  return testScope(repository: repository, child: const CampusFlowApp());
}
