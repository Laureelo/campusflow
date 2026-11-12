class Task {
  final String title;
  final String? description;

  const Task({required this.title, this.description});
}

String summaryWithDefault(Task task) {
  return '${task.title} : ${(task.description ?? 'None').trim()}';
}

String summaryWithIf(Task task) {
  final description = task.description;
  if (description == null) {
    return '${task.title} : no description';
  }
  return '${task.title} : ${description.trim()}';
}

String summaryWithSafeCall(Task task) {
  final trimmed = task.description?.trim();
  return trimmed == null ? task.title : '${task.title} : $trimmed';
}

void main() {
  const withDescription = Task(title: 'Dart workshop', description: '  Models  ');
  const withoutDescription = Task(title: 'Flutter workshop');

  for (final task in [withDescription, withoutDescription]) {
    print(summaryWithDefault(task));
    print(summaryWithIf(task));
    print(summaryWithSafeCall(task));
    print('---');
  }
}
