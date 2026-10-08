// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// ==================== TAHAP 5 + TAHAP 11 + TAHAP 13 ====================
// Arah dependency: UI -> CourseProvider -> CourseRepository -> CourseService
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