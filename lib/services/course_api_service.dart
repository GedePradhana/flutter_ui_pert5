import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'course_data_source.dart';

// ==================== TAHAP 4 + TAHAP 9 ====================
// CourseApiService: satu-satunya tempat yang tahu DETAIL TEKNIS
// komunikasi dengan REST API (http.get, jsonDecode, endpoint).
// CourseRepository dan layer di atasnya tidak perlu tahu ini --
// cukup panggil getCourses(). Ini menggantikan CourseService
// (JSON lokal) dari Pertemuan 6.
//
// Pada Tahap 9, class ini implements CourseDataSource supaya bisa
// dipertukarkan dengan sumber data lain tanpa mengubah CourseRepository.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseApiService implements CourseDataSource {
  CourseApiService(this.baseUrl);

  final String baseUrl;

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

  @override
  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course');
    }

    final List data = jsonDecode(response.body) as List;

    return data
        .map(
          (e) => Course.fromJson(
            _adaptTodoToCourseJson(e as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception('Gagal membuat course');
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memperbarui course');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menghapus course');
    }
  }
}