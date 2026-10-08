import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// ==================== TAHAP 5 + TAHAP 11 ====================
// ChangeNotifier dan notifyListeners()
// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// TAHAP 5-7: class ini menangani shared state favorites.
// TAHAP 11: class ini juga menangani async state (courses,
// isLoading, error) dengan mengambil data lewat CourseRepository.
//
// Arah dependency: UI -> CourseProvider -> CourseRepository -> CourseService
class CourseProvider extends ChangeNotifier {
  // TAHAP 11: repository diterima lewat constructor, jadi Provider
  // tidak tahu apakah data berasal dari JSON, API, atau database.
  final CourseRepository repository;

  CourseProvider(this.repository);

  // ==================== ASYNC STATE (TAHAP 11) ====================
  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCourses() async {
    // 1) Mulai loading, bersihkan error lama, beri tahu UI.
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // 2) Ambil data lewat repository (bukan rootBundle langsung).
      courses = await repository.getCourses();
    } catch (e) {
      // 3) Simpan pesan error supaya UI bisa menampilkannya.
      error = e.toString();
    } finally {
      // 4) Apa pun hasilnya, loading selesai, beri tahu UI lagi.
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== SHARED STATE FAVORITES (TAHAP 5) ====================
  // Daftar kode course yang difavoritkan.
  final Set<String> favorites = {};

  // Method perubahan state. WAJIB memanggil notifyListeners()
  // setelah state berubah, supaya semua widget yang "mendengarkan"
  // CourseProvider ini ikut rebuild dengan nilai terbaru.
  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  // Helper kecil untuk mengecek status favorite satu course,
  // supaya UI tidak perlu mengakses .favorites.contains() langsung.
  bool isFavorite(String code) {
    return favorites.contains(code);
  }
}