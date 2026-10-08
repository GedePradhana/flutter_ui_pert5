// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

// TAHAP 13: halaman detail membaca status favorite dari
// CourseProvider yang SAMA dengan list dan FavoritesPage.
class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    // select -> halaman hanya rebuild kalau status favorite
    // course INI yang berubah.
    final isFavorite = context.select<CourseProvider, bool>(
      (provider) => provider.isFavorite(course.code),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'NIM: 2415051030',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 72,
                color: isFavorite ? Colors.red : null,
              ),
              const SizedBox(height: 16),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${course.code} • ${course.credits} SKS'),
              const SizedBox(height: 4),
              Text('Status: ${course.status}'),
              const SizedBox(height: 12),
              Text(
                isFavorite
                    ? 'Course ini ada di favorit'
                    : 'Course ini belum difavoritkan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<CourseProvider>()
                      .toggleFavorite(course.code);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: Text(
                  isFavorite
                      ? 'Hapus dari Favorit'
                      : 'Tambah ke Favorit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}