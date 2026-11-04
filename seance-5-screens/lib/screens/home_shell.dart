import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/course.dart';
import '../models/task.dart';
import 'courses_list.dart';
import 'deadlines_list.dart';
import 'task_detail.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final List<Task> _tasks = buildSampleTasks();
  int _selectedIndex = 0;

  Course? _courseOf(Task task) {
    return sampleCourses
        .where((course) => course.id == task.courseId)
        .firstOrNull;
  }

  void _markDone(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    setState(() => _tasks[index] = task.copyWith(done: true));
  }

  void _openDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          course: _courseOf(task),
          onMarkDone: () {
            _markDone(task);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onDeadlines = _selectedIndex == 0;

    return Scaffold(
      appBar: AppBar(title: Text(onDeadlines ? 'Deadlines' : 'Courses')),
      body: onDeadlines
          ? DeadlinesList(
              tasks: _tasks,
              courses: sampleCourses,
              onTaskTap: _openDetail,
            )
          : const CoursesList(courses: sampleCourses),
      floatingActionButton: onDeadlines
          ? FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add a deadline',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Deadlines'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Courses'),
        ],
      ),
    );
  }
}
