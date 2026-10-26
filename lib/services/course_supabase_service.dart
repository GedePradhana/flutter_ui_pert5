import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// ==================== TAHAP 12 + TAHAP 13 + TAHAP 14 ====================
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
  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(row);
  }

  // TAHAP 14: UPDATE courses SET code=..., title=..., credits=...,
  // status=... WHERE id = :id
  // - update(course.toJson()) mengirim field yang diubah.
  // - eq('id', id) WAJIB ada sebagai filter. Tanpa filter ini,
  //   UPDATE akan mengenai SEMUA baris di tabel.
  // Signature sama dengan kontrak CourseDataSource.
  @override
  Future<void> updateCourse(int id, Course course) async {
    await supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id);
  }

  // Sementara, agar kelas tetap dapat dikompilasi.
  // Dikerjakan di Tahap 15.
  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}