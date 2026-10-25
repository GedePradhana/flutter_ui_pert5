// ==================== TAHAP 3 ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// Halaman SEMENTARA untuk membuktikan hasil Course.fromJson() dari
// REST API bisa ditampilkan di UI, bukan cuma debugPrint. Halaman
// ini akan digantikan oleh alur CourseApiService -> CourseRepository
// -> CourseProvider yang sudah ada begitu Tahap 4-5 selesai; untuk
// sekarang cukup FutureBuilder langsung memanggil fetchCoursesAsModelTest().

import 'package:flutter/material.dart';

import 'models/course.dart';
import 'temp_http_test.dart';

class TempRestCoursesPage extends StatelessWidget {
  const TempRestCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes REST (Tahap 3)'),
      ),
      body: FutureBuilder<List<Course>>(
        future: fetchCoursesAsModelTest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final courses = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            // Minimal tiga course ditampilkan sesuai worksheet.
            itemCount: courses.length < 3 ? courses.length : 3,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(course.code),
                  subtitle: Text(course.title),
                  trailing: Text(course.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}