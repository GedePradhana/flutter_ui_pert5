import '../models/course.dart';
import '../services/course_service.dart';

// ==================== TAHAP 10 ====================
// CourseRepository: lapisan abstraksi antara state/business logic
// dan sumber data. Pemanggil cukup tahu getCourses(), tidak perlu
// tahu data berasal dari JSON, API, atau database.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseRepository {
  final CourseService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }
}