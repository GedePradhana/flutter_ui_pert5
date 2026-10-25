// ==================== TAHAP 2 & 3 ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// File ini SEMENTARA. Isinya untuk mencoba package http dan
// Course.fromJson(), SEBELUM kodenya dipindah ke CourseApiService
// pada Tahap 4. File ini (dan temp_rest_courses_page.dart) tidak
// menjadi bagian permanen arsitektur -- akan digantikan sepenuhnya
// begitu CourseApiService + CourseRepository selesai di Tahap 4.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/course.dart';

// Endpoint latihan (dummy, belum ada dari dosen).
// Operasi write ke endpoint ini hanya disimulasikan, tidak persisten.
const String apiUrl = 'https://jsonplaceholder.typicode.com/todos';

// Kalau mau sengaja lihat error (sesuai instruksi worksheet Tahap 2),
// ganti sementara jadi url yang salah saat memanggil
// fetchCoursesTest(), lalu kembalikan lagi ke apiUrl yang benar:
//
//   await fetchCoursesTest(url: 'https://jsonplaceholder.typicode.com/todosxxx');

Future<List<dynamic>> fetchCoursesTest({String url = apiUrl}) async {
  final response = await http.get(Uri.parse(url));

  // WAJIB cek status code dulu sebelum memproses body-nya.
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  throw Exception('HTTP ${response.statusCode}');
}

// ==================== TAHAP 3 ====================
// Endpoint latihan (/todos) field-nya tidak sama dengan Course
// (code/title/credits/status), jadi di sinilah penyesuaiannya
// dilakukan -- BUKAN di dalam Course.fromJson(), supaya model
// Course tetap bersih dan generik sesuai contoh worksheet
// (dipakai lagi nanti untuk endpoint dosen & tabel Supabase yang
// field-nya memang sudah code/title/credits/status).
Map<String, dynamic> _adaptTodoToCourseJson(Map<String, dynamic> todo) {
  final id = todo['id'] as int;
  final userId = todo['userId'] as int;
  final completed = todo['completed'] as bool;

  return {
    'id': id,
    'code': 'MOB${id.toString().padLeft(2, '0')}',
    'title': todo['title'] as String,
    'credits': (userId % 3) + 1, // dibuat variatif 1-3
    'status': completed ? 'done' : 'planned',
  };
}

// Konversi response list (List<dynamic>) menjadi List<Course>.
Future<List<Course>> fetchCoursesAsModelTest({String url = apiUrl}) async {
  final rawList = await fetchCoursesTest(url: url);

  return rawList
      .map(
        (e) => Course.fromJson(
          _adaptTodoToCourseJson(e as Map<String, dynamic>),
        ),
      )
      .toList();
}

// Dipanggil sekali dari main() untuk menguji, lihat hasilnya
// di Debug Console.
Future<void> runHttpGetTest() async {
  try {
    final rawData = await fetchCoursesTest();

    debugPrint(
      '[Tahap 2] 2415051030 - I Gede Pradhana Subawa Deningrat: '
      'berhasil GET, jumlah item = ${rawData.length}',
    );

    final courses = await fetchCoursesAsModelTest();

    debugPrint(
      '[Tahap 3] Berhasil konversi ke List<Course>, '
      'jumlah = ${courses.length}',
    );

    for (final course in courses.take(3)) {
      debugPrint(
        '[Tahap 3] ${course.code} - ${course.title} '
        '(${course.status})',
      );
    }
  } catch (e) {
    debugPrint('[Tahap 2/3] GAGAL fetch: $e');
  }
}