import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import 'auth_provider.dart';
import 'data_providers.dart';

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final signedIn = await ref.watch(authProvider.future);
  if (!signedIn) return const [];
  return ref.watch(courseRepositoryProvider).getAll();
});
