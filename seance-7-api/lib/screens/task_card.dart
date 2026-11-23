import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/format.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String courseName;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.courseName,
    required this.onTap,
    required this.onToggle,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = task.isOverdue(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        selected: selected,
        selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.4),
        leading: Checkbox(
          value: task.done,
          shape: const CircleBorder(),
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: task.done
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: scheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Text('$courseName • ${formatDate(task.dueDate)}'),
        trailing: overdue ? const _OverdueBadge() : null,
        onTap: onTap,
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Overdue',
        style: TextStyle(
          color: scheme.onErrorContainer,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
