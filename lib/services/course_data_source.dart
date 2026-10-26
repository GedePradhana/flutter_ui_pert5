import '../models/course.dart';

// ==================== TAHAP 9 ====================
// CourseDataSource: kontrak (abstract class) yang dipakai CourseRepository.
// Dengan ini, repository/provider/UI tidak perlu tahu apakah data
// berasal dari REST, Supabase, cache, atau sumber lain.
// I Gede Pradhana Subawa Deningrat
// 2415051030
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}