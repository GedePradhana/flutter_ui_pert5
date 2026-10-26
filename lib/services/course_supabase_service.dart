import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'app_exception.dart';
import 'course_data_source.dart';

// ==================== TAHAP 12 + 13 + 14 + 15 + 17 ====================
// CourseSupabaseService: sumber data yang membaca dan menulis tabel
// `courses` di Supabase (PostgreSQL). Class ini implements
// CourseDataSource, sehingga bisa menggantikan REST API tanpa
// mengubah Repository, Provider, maupun UI.
//
// Tahap 17: setiap operasi dibungkus _guard() yang menerjemahkan
// PostgrestException (kode PostgreSQL / PostgREST), timeout, error
// parsing, dan tidak ada internet menjadi AppException.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseSupabaseService implements CourseDataSource {
  // Client Supabase yang sudah diinisialisasi di main()
  // lewat Supabase.initialize().
  final SupabaseClient supabase = Supabase.instance.client;

  static const Duration _timeout = Duration(seconds: 10);

  // ==================== TAHAP 17: PENANGANAN ERROR ====================
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(_timeout);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _fromPostgrest(e);
    } catch (e) {
      throw AppException.wrap(e);
    }
  }

  // Kasus A, D, E: kode error dari PostgREST / PostgreSQL.
  AppException _fromPostgrest(PostgrestException e) {
    final code = e.code ?? '';

    switch (code) {
      // Kasus D: RLS / permission ditolak.
      case '42501':
      case '403':
        return AppException(
          AppErrorType.forbidden,
          'Akses ditolak oleh policy keamanan database (RLS/permission). '
          'Periksa policy tabel courses (kode $code).',
          statusCode: 403,
        );

      case '401':
      case 'PGRST301':
        return AppException(
          AppErrorType.unauthorized,
          'API key tidak valid atau sesi kedaluwarsa (kode $code).',
          statusCode: 401,
        );

      // Kasus A: tabel / endpoint tidak ada.
      case 'PGRST205':
      case '42P01':
      case '404':
        return AppException(
          AppErrorType.notFound,
          'Tabel atau endpoint tidak ditemukan di Supabase '
          '(kode $code). Periksa nama tabel.',
          statusCode: 404,
        );

      // Kasus E: data melanggar constraint.
      case '23505':
        return AppException(
          AppErrorType.conflict,
          'Data duplikat: nilai tersebut sudah ada di database '
          '(unique constraint).',
          statusCode: 409,
        );
      case '23514':
        return AppException(
          AppErrorType.validation,
          'Data melanggar aturan database (CHECK constraint), mis. '
          'credits harus lebih dari 0 dan status harus '
          'planned/active/done.',
          statusCode: 400,
        );
      case '23502':
        return AppException(
          AppErrorType.validation,
          'Ada kolom wajib yang kosong (NOT NULL constraint).',
          statusCode: 400,
        );
      case '22P02':
        return AppException(
          AppErrorType.validation,
          'Format data tidak sesuai tipe kolom di database.',
          statusCode: 400,
        );
    }

    final status = int.tryParse(code);
    if (status != null && status >= 500) {
      return AppException.fromStatus(status);
    }

    return AppException(
      AppErrorType.unknown,
      'Database menolak permintaan: ${e.message} (kode $code).',
    );
  }

  // TAHAP 12: SELECT * FROM courses ORDER BY id
  @override
  Future<List<Course>> getCourses() {
    return _guard(() async {
      final data = await supabase
          .from('courses')
          .select()
          .order('id');

      // Kasus C: kalau key/tipe JSON tidak cocok, Course.fromJson
      // melempar TypeError -> diubah menjadi AppException.parsing().
      return (data as List)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // TAHAP 13: INSERT INTO courses (...) VALUES (...) RETURNING *
  @override
  Future<Course> createCourse(Course course) {
    return _guard(() async {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      return Course.fromJson(row);
    });
  }

  // TAHAP 14: UPDATE courses SET code=..., title=..., credits=...,
  // status=... WHERE id = :id
  // - eq('id', id) WAJIB ada sebagai filter. Tanpa filter ini,
  //   UPDATE akan mengenai SEMUA baris di tabel.
  //
  // TAHAP 17: .select() ditambahkan supaya hasilnya bisa dicek.
  // Saat RLS memblokir UPDATE, Supabase TIDAK melempar error;
  // request "berhasil" tetapi 0 baris berubah. Tanpa pengecekan
  // ini, UI akan menampilkan "berhasil diperbarui" padahal tidak
  // ada yang berubah.
  @override
  Future<void> updateCourse(int id, Course course) {
    return _guard(() async {
      final rows = await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id)
          .select();

      if (rows.isEmpty) {
        throw const AppException(
          AppErrorType.forbidden,
          'Tidak ada data yang diubah. Course tidak ditemukan atau '
          'perubahan ditolak oleh policy RLS.',
        );
      }
    });
  }

  // TAHAP 15: DELETE FROM courses WHERE id = :id
  // - eq('id', id) WAJIB ada sebagai filter. Tanpa filter ini,
  //   DELETE akan menghapus SEMUA baris di tabel.
  //
  // TAHAP 17: sama seperti update, hasil dicek karena DELETE yang
  // diblokir RLS juga tidak melempar error.
  @override
  Future<void> deleteCourse(int id) {
    return _guard(() async {
      final rows = await supabase
          .from('courses')
          .delete()
          .eq('id', id)
          .select();

      if (rows.isEmpty) {
        throw const AppException(
          AppErrorType.forbidden,
          'Tidak ada data yang dihapus. Course tidak ditemukan atau '
          'penghapusan ditolak oleh policy RLS.',
        );
      }
    });
  }
}