import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'app_exception.dart';
import 'course_data_source.dart';

// ==================== TAHAP 4 + TAHAP 9 + TAHAP 17 ====================
// CourseApiService: satu-satunya tempat yang tahu DETAIL TEKNIS
// komunikasi dengan REST API (http.get, jsonDecode, endpoint).
// CourseRepository dan layer di atasnya tidak perlu tahu ini --
// cukup panggil getCourses(). Ini menggantikan CourseService
// (JSON lokal) dari Pertemuan 6.
//
// Pada Tahap 9, class ini implements CourseDataSource supaya bisa
// dipertukarkan dengan sumber data lain tanpa mengubah CourseRepository.
//
// Pada Tahap 17, setiap request dibungkus _guard(): timeout,
// pengecekan status code (404, 500, dst.), deteksi tidak ada
// internet, dan error parsing JSON, semuanya menjadi AppException.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseApiService implements CourseDataSource {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  static const Duration _timeout = Duration(seconds: 10);

  Map<String, dynamic> _adaptTodoToCourseJson(Map<String, dynamic> todo) {
    final id = todo['id'] as int;
    final userId = todo['userId'] as int;
    final completed = todo['completed'] as bool;

    return {
      'id': id,
      'code': 'MOB${id.toString().padLeft(2, '0')}',
      'title': todo['title'] as String,
      'credits': (userId % 3) + 1,
      'status': completed ? 'done' : 'planned',
    };
  }

  // Pembungkus error: semua exception keluar sebagai AppException.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(_timeout);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.wrap(e);
    }
  }

  // Status 2xx dianggap sukses; selain itu dilempar sesuai kodenya.
  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException.fromStatus(response.statusCode);
    }
  }

  @override
  Future<List<Course>> getCourses() {
    return _guard(() async {
      final response = await http.get(Uri.parse('$baseUrl/todos'));
      _ensureSuccess(response);

      final List data = jsonDecode(response.body) as List;

      return data
          .map(
            (e) => Course.fromJson(
              _adaptTodoToCourseJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    });
  }

  @override
  Future<Course> createCourse(Course course) {
    return _guard(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(course.toJson()),
      );
      _ensureSuccess(response);

      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<void> updateCourse(int id, Course course) {
    return _guard(() async {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(course.toJson()),
      );
      _ensureSuccess(response);
    });
  }

  @override
  Future<void> deleteCourse(int id) {
    return _guard(() async {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
      );
      _ensureSuccess(response);
    });
  }
}