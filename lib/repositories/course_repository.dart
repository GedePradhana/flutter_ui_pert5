import '../models/course.dart';
import '../services/course_api_service.dart';

// ==================== TAHAP 10 (Pertemuan 6) + TAHAP 4 (Pertemuan 7) ====================
// CourseRepository: lapisan abstraksi antara state/business logic
// dan sumber data. Pemanggil (CourseProvider) cukup tahu getCourses(),
// tidak perlu tahu data berasal dari JSON, REST API, atau database.
//
// Dependency diganti dari CourseService (JSON lokal) menjadi
// CourseApiService (REST API). CourseProvider di atasnya TIDAK
// perlu diubah sama sekali karena tetap memanggil
// repository.getCourses() seperti biasa.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  // ==================== TAHAP 6 ====================
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }
}