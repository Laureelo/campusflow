import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/course_tasks_screen.dart';
import '../screens/courses_list.dart';
import '../screens/deadlines_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/shell_scaffold.dart';
import '../screens/task_detail.dart';
import '../screens/task_form.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authChanges = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => authChanges.value++);

  final router = GoRouter(
    initialLocation: '/taches',
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;

      final signedIn = auth.value ?? false;
      final onLogin = state.matchedLocation == '/login';

      if (!signedIn && !onLogin) return '/login';
      if (signedIn && onLogin) return '/taches';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/taches',
            builder: (context, state) => const DeadlinesScreen(),
          ),
          GoRoute(
            path: '/cours',
            builder: (context, state) => const CoursesList(),
          ),
          GoRoute(
            path: '/profil',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/cours/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return CourseTasksScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/taches/nouvelle',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/taches/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return TaskDetailScreen(taskId: id);
        },
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authChanges.dispose();
  });
  return router;
});
