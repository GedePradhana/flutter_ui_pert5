import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// ==================== TAHAP 12 + TAHAP 13 ====================
// CourseSupabaseService: sumber data yang membaca dan menulis tabel
// `courses` di Supabase (PostgreSQL). Class ini implements
// CourseDataSource, sehingga bisa menggantikan REST API tanpa
// mengubah Repository, Provider, maupun UI.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseSupabaseService implements CourseDataSource {
  // Client Supabase yang sudah diinisialisasi di main()
  // lewat Supabase.initialize().
  final SupabaseClient supabase = Supabase.instance.client;

  // TAHAP 12: SELECT * FROM courses ORDER BY id
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

  // TAHAP 13: INSERT INTO courses (...) VALUES (...) RETURNING *
  // - insert(course.toJson()) mengirim code, title, credits, status
  //   (id dan created_at dibuat otomatis oleh database).
  // - select() meminta row yang baru dibuat dikembalikan.
  // - single() mengambil tepat satu row (bukan list).
  // Return type Course sama seperti versi REST, sehingga
  // CourseRepository tidak perlu diubah.
  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(row);
  }

  // Sementara, agar kelas tetap dapat dikompilasi.
  // Dikerjakan di Tahap 14-15.
  @override
  Future<void> updateCourse(int id, Course course) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}