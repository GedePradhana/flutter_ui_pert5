import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/course.dart';

// ==================== TAHAP 9 ====================
// CourseService: satu-satunya tempat yang tahu DETAIL TEKNIS
// sumber data (saat ini file JSON di assets). Nanti kalau sumber
// data diganti ke API, cukup isi class ini yang diubah; screen
// tidak perlu disentuh.
// Return type sudah List<Course>, bukan List<Map> lagi.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseService {
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;

    final courses = list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();

    // debugPrint SEMENTARA untuk menguji service (lihat di Debug
    // Console). Boleh dihapus setelah screenshot bukti diambil.
    debugPrint(
      '[CourseService] 2415051030 - I Gede Pradhana Subawa Deningrat: '
      '${courses.length} course dimuat',
    );
    for (final course in courses) {
      debugPrint(
        '[CourseService] ${course.code} | ${course.title} | '
        '${course.credits} SKS | ${course.status}',
      );
    }

    return courses;
  }
}