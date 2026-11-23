import 'package:dio/dio.dart';

import '../core/api_exception.dart';
import '../models/task.dart';
import 'task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  final Dio _dio;

  ApiTaskRepository(this._dio);

  @override
  Future<List<Task>> getAll() {
    return guardApi(() async {
      final response = await _dio.get<List<dynamic>>('/taches');
      final items = response.data ?? const [];
      return [
        for (final item in items) Task.fromJson(item as Map<String, dynamic>),
      ];
    });
  }

  @override
  Future<Task> create({
    required String title,
    required DateTime dueDate,
    required int courseId,
  }) {
    return guardApi(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/taches',
        data: {
          'title': title,
          'dueDate': dueDate.toIso8601String(),
          'done': false,
          'courseId': courseId,
        },
      );
      return Task.fromJson(response.data!);
    });
  }

  @override
  Future<Task> setDone(int id, {required bool done}) {
    return guardApi(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/taches/$id',
        data: {'done': done},
      );
      return Task.fromJson(response.data!);
    });
  }

  @override
  Future<void> delete(int id) {
    return guardApi(() => _dio.delete<void>('/taches/$id'));
  }
}
