import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/course.dart';
import '../providers/courses_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/format.dart';
import '../utils/run_action.dart';
import 'error_view.dart';

class TaskDetailView extends ConsumerWidget {
  final int taskId;
  final VoidCallback? onDeleted;

  const TaskDetailView({super.key, required this.taskId, this.onDeleted});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this deadline?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final deleted = await runAction(
      context,
      () => ref.read(tasksProvider.notifier).delete(taskId),
    );
    if (deleted) onDeleted?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return tasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          ErrorView(error: error, onRetry: () => ref.invalidate(tasksProvider)),
      data: (list) {
        final task = list.where((task) => task.id == taskId).firstOrNull;

        if (task == null) {
          return const Center(child: Text('Task not found'));
        }

        final course = (ref.watch(coursesProvider).value ?? const <Course>[])
            .where((course) => course.id == task.courseId)
            .firstOrNull;
        final overdue = task.isOverdue(DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text('Course: ${course?.name ?? 'Unknown course'}'),
                      Text('Teacher: ${course?.teacher ?? '-'}'),
                      Text('Due date: ${formatDate(task.dueDate)}'),
                      Text(
                        'Status: ${task.done
                            ? 'Done'
                            : overdue
                            ? 'Overdue'
                            : 'To do'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: task.done
                    ? null
                    : () => runAction(
                        context,
                        () =>
                            ref.read(tasksProvider.notifier).markDone(task.id),
                      ),
                child: const Text('Mark as done'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _confirmDelete(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deadline')),
      body: TaskDetailView(taskId: taskId, onDeleted: () => context.pop()),
    );
  }
}
