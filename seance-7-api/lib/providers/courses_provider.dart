import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import 'data_providers.dart';

final coursesProvider = FutureProvider<List<Course>>((ref) {
  return ref.watch(courseRepositoryProvider).getAll();
});
