import 'package:campusflow_api/core/token_storage.dart';
import 'package:campusflow_api/data/auth_repository.dart';
import 'package:campusflow_api/data/course_repository.dart';
import 'package:campusflow_api/data/fake_task_repository.dart';
import 'package:campusflow_api/main.dart';
import 'package:campusflow_api/providers/auth_provider.dart';
import 'package:campusflow_api/providers/data_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'sample_data.dart';

FakeTaskRepository sampleRepository({Duration delay = Duration.zero}) {
  return FakeTaskRepository(tasks: buildSampleTasks(), delay: delay);
}

TokenStorage signedInStorage() => MemoryTokenStorage('test-token');

List<Override> testOverrides(
  FakeTaskRepository repository, {
  TokenStorage? tokenStorage,
}) {
  return [
    taskRepositoryProvider.overrideWithValue(repository),
    courseRepositoryProvider.overrideWithValue(
      const FakeCourseRepository(sampleCourses),
    ),
    authRepositoryProvider.overrideWithValue(
      const FakeAuthRepository(user: sampleUser),
    ),
    tokenStorageProvider.overrideWithValue(tokenStorage ?? signedInStorage()),
  ];
}

ProviderContainer testContainer(
  FakeTaskRepository repository, {
  TokenStorage? tokenStorage,
}) {
  return ProviderContainer(
    retry: (_, _) => null,
    overrides: testOverrides(repository, tokenStorage: tokenStorage),
  );
}

Widget testScope({
  required Widget child,
  FakeTaskRepository? repository,
  TokenStorage? tokenStorage,
}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: testOverrides(
      repository ?? sampleRepository(),
      tokenStorage: tokenStorage,
    ),
    child: child,
  );
}

Widget buildTestApp({
  FakeTaskRepository? repository,
  TokenStorage? tokenStorage,
}) {
  return testScope(
    repository: repository,
    tokenStorage: tokenStorage,
    child: const CampusFlowApp(),
  );
}
