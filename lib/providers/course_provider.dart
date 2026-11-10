// ==================== TAHAP 15: CHECKLIST DEBUGGING ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
// UI tidak berubah padahal data berubah? Periksa berurutan:
// 1. Apakah notifyListeners() dipanggil setelah state berubah? (Kasus A)
// 2. Apakah widget memakai watch/Consumer/select, bukan read?
// 3. Apakah context berada di bawah ChangeNotifierProvider? (Kasus B)
// 4. Apakah error async ditangkap dan disimpan di state? (Kasus C)
// 5. Apakah mounted dicek sebelum setState/context setelah await? (Kasus D)
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// ==================== TAHAP 5 + TAHAP 11 + TAHAP 13 ====================
// Arah dependency: UI -> CourseProvider -> CourseRepository -> CourseApiService
class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  // ==================== ASYNC STATE (TAHAP 11) ====================
  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== TAHAP 6 (Pertemuan 7) ====================
  // isSaving: flag terpisah dari isLoading, supaya "menyimpan data
  // baru" dan "memuat daftar course" tidak saling tiban status-nya.
  // Dipakai form untuk menonaktifkan tombol Simpan dan mencegah
  // submit ganda (lihat Pertemuan 5 Tahap 16 Kasus D).
  bool isSaving = false;

  // Sengaja TIDAK menangkap try/catch di sini -- exception dibiarkan
  // lempar ke pemanggil (screen), supaya screen bisa menampilkan
  // SnackBar sukses/gagal sesuai hasilnya masing-masing.
  Future<void> createCourse(Course course) async {
    isSaving = true;
    notifyListeners();

    try {
      await repository.createCourse(course);

      // Refresh list dengan memuat ulang dari server (mengganti
      // isi list), BUKAN menambahkan item baru secara manual ke
      // `courses` -- sesuai instruksi worksheet.
      await loadCourses();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ==================== TAHAP 7 ====================
  // Guard submit ganda yang sama (isSaving) dipakai ulang di sini,
  // tidak perlu flag terpisah untuk create vs update.
  Future<void> updateCourse(int id, Course course) async {
    isSaving = true;
    notifyListeners();

    try {
      await repository.updateCourse(id, course);
      await loadCourses();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ==================== TAHAP 8 ====================
  // code opsional: kalau diisi, code tersebut juga dihapus dari
  // favorites supaya tidak ada "data yatim" (favorit yang
  // menunjuk ke course yang sudah tidak ada lagi).
  Future<void> deleteCourse(int id, {String? code}) async {
    isSaving = true;
    notifyListeners();

    try {
      await repository.deleteCourse(id);

      if (code != null) {
        favorites.remove(code);
      }

      await loadCourses();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ==================== WORKSHEET 9 ====================
  // Dipanggil saat logout supaya data user sebelumnya tidak tersisa.
  void reset() {
    courses = [];
    favorites.clear();
    error = null;
    isLoading = false;
    isSaving = false;
    notifyListeners();
  }

  // ==================== SHARED STATE FAVORITES (TAHAP 5) ====================
  final Set<String> favorites = {};

  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  // ==================== TAHAP 13 ====================
  // Course yang difavoritkan, dipakai FavoritesPage.
  // Diturunkan dari courses + favorites, jadi tidak ada state ganda.
  List<Course> get favoriteCourses {
    return courses
        .where((course) => favorites.contains(course.code))
        .toList();
  }
}