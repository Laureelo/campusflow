import 'package:dio/dio.dart';

import '../core/api_exception.dart';
import '../models/course.dart';

abstract interface class CourseRepository {
  Future<List<Course>> getAll();
}

class ApiCourseRepository implements CourseRepository {
  final Dio _dio;

  ApiCourseRepository(this._dio);

  @override
  Future<List<Course>> getAll() {
    return guardApi(() async {
      final response = await _dio.get<List<dynamic>>('/cours');
      final items = response.data ?? const [];
      return [
        for (final item in items) Course.fromJson(item as Map<String, dynamic>),
      ];
    });
  }
}

class FakeCourseRepository implements CourseRepository {
  final List<Course> courses;

  const FakeCourseRepository(this.courses);

  @override
  Future<List<Course>> getAll() async => courses;
}
