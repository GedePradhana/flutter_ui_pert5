// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'edit_course_page.dart';

// TAHAP 13: halaman detail membaca status favorite dari
// CourseProvider yang SAMA dengan list dan FavoritesPage.
// TAHAP 16: `course` tetap diterima lewat constructor, tetapi data
// yang DITAMPILKAN diambil ulang dari provider (berdasarkan id)
// supaya setelah Edit + refresh dari database, halaman detail
// tidak menampilkan data lama.
class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  // ==================== TAHAP 8 ====================
  // AlertDialog konfirmasi SEBELUM menghapus.
  Future<void> _confirmAndDelete(
    BuildContext context,
    CourseProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Course'),
          content: Text(
            'Yakin ingin menghapus "${course.title}"? '
            'Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Pengguna memilih Batal, atau dialog ditutup tanpa memilih.
    if (confirmed != true) return;

    final id = course.id;
    if (id == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course ini tidak punya id, tidak bisa dihapus'),
        ),
      );
      return;
    }

    try {
      // code dikirim juga supaya kalau course ini sedang
      // difavoritkan, ikut dibersihkan dari favorites (tidak
      // tersisa data yatim).
      await provider.deleteCourse(id, code: course.code);

      // Setelah await DELETE, WAJIB cek mounted sebelum
      // menampilkan SnackBar atau memanggil Navigator.pop().
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil dihapus'),
        ),
      );

      // Keluar dari halaman detail -- course-nya sudah tidak ada.
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TAHAP 16: ambil versi terbaru course ini dari provider.
    // Kalau tidak ditemukan (mis. sedang dihapus), pakai course
    // dari constructor.
    final current = context.select<CourseProvider, Course>(
      (provider) => provider.courses.firstWhere(
        (c) => c.id != null && c.id == course.id,
        orElse: () => course,
      ),
    );

    // select -> halaman hanya rebuild kalau status favorite
    // course INI yang berubah.
    final isFavorite = context.select<CourseProvider, bool>(
      (provider) => provider.isFavorite(current.code),
    );

    // isSaving dipakai untuk menonaktifkan tombol Edit/Delete
    // selagi ada request (create/update/delete) sedang berjalan.
    final isSaving = context.select<CourseProvider, bool>(
      (provider) => provider.isSaving,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
        actions: [
          // ==================== TAHAP 7 ====================
          IconButton(
            tooltip: 'Edit Course',
            icon: const Icon(Icons.edit_outlined),
            onPressed: isSaving
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCoursePage(course: current),
                      ),
                    );
                  },
          ),

          // ==================== TAHAP 8 ====================
          IconButton(
            tooltip: 'Hapus Course',
            icon: const Icon(Icons.delete_outline),
            onPressed: isSaving
                ? null
                : () {
                    _confirmAndDelete(
                      context,
                      context.read<CourseProvider>(),
                    );
                  },
          ),
        ],
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
                current.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${current.code} • ${current.credits} SKS'),
              const SizedBox(height: 4),
              Text('Status: ${current.status}'),
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
                      .toggleFavorite(current.code);
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