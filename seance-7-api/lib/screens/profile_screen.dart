import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/user_provider.dart';
import 'error_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final now = DateTime.now();
    final done = tasks.where((task) => task.done).length;
    final overdue = tasks.where((task) => task.isOverdue(now)).length;
    final todo = tasks.length - done;

    return user.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(userProvider)),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.substring(0, 1),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user.email),
              Text('${user.age} years old'),
              const SizedBox(height: 24),
              Row(
                children: [
                  _StatCard(label: 'To do', value: todo),
                  _StatCard(label: 'Done', value: done),
                  _StatCard(label: 'Late', value: overdue, alert: overdue > 0),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool alert;

  const _StatCard({
    required this.label,
    required this.value,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: alert ? scheme.error : null),
              ),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
