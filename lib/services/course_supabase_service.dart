import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// ==================== TAHAP 12 ====================
// CourseSupabaseService: sumber data baru yang membaca tabel
// `courses` di Supabase (PostgreSQL). Sama seperti CourseApiService,
// class ini implements CourseDataSource, sehingga bisa menggantikan
// REST API tanpa mengubah Repository, Provider, maupun UI.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseSupabaseService implements CourseDataSource {
  // Client Supabase yang sudah diinisialisasi di main()
  // lewat Supabase.initialize().
  final SupabaseClient supabase = Supabase.instance.client;

  // SELECT * FROM courses ORDER BY id
  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sementara, agar kelas tetap dapat dikompilasi.
  // Dikerjakan di Tahap 13-15.
  @override
  Future<Course> createCourse(Course course) =>
      throw UnimplementedError();

  @override
  Future<void> updateCourse(int id, Course course) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}