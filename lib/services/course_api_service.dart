import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

// ==================== TAHAP 4 ====================
// CourseApiService: satu-satunya tempat yang tahu DETAIL TEKNIS
// komunikasi dengan REST API (http.get, jsonDecode, endpoint).
// CourseRepository dan layer di atasnya tidak perlu tahu ini --
// cukup panggil getCourses(). Ini menggantikan CourseService
// (JSON lokal) dari Pertemuan 6.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // Endpoint latihan (/todos) field-nya belum berbentuk
  // code/title/credits/status seperti domain Course, jadi
  // disesuaikan di sini (pindahan dari temp_http_test.dart Tahap 3).
  //
  // CATATAN UNTUK NANTI: kalau endpoint resmi dari dosen sudah
  // berbentuk course asli (id/code/title/credits/status, seperti
  // contoh di Tahap 1), cukup HAPUS _adaptTodoToCourseJson() dan
  // panggil Course.fromJson(e) langsung -- persis seperti contoh
  // di materi worksheet.
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

  // ==================== TAHAP 6 ====================
  // POST ke endpoint latihan. Karena yang dikirim adalah
  // course.toJson() (code/title/credits/status, field yang sama
  // seperti contoh di worksheet), response dari JSONPlaceholder
  // akan meng-echo balik field yang sama persis + id baru --
  // jadi TIDAK perlu adapter seperti di getCourses().
  //
  // CATATAN: JSONPlaceholder adalah fake API; data yang "dibuat"
  // di sini tidak benar-benar tersimpan di server (hilang lagi
  // kalau di-refresh/di-reload dari awal). Ini sudah diperingatkan
  // di materi Tahap 1.
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

  // ==================== TAHAP 7 ====================
  // PUT ke /todos/{id} -- merepresentasikan PENGGANTIAN resource
  // (bukan perubahan sebagian seperti PATCH). JSONPlaceholder akan
  // meng-echo balik data yang dikirim, tapi kita tidak perlu
  // mem-parsing responsnya karena updateCourse() cukup memberi
  // tahu berhasil/gagal (Future<void>), sama seperti contoh di
  // worksheet.
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

  // ==================== TAHAP 8 ====================
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menghapus course');
    }
  }
}