import '../models/course.dart';
import '../services/course_data_source.dart';

// ==================== TAHAP 10 (Pertemuan 6) + TAHAP 4 (Pertemuan 7) + TAHAP 9 ====================
// CourseRepository: lapisan abstraksi antara state/business logic
// dan sumber data. Pemanggil (CourseProvider) cukup tahu getCourses(),
// tidak perlu tahu data berasal dari JSON, REST API, atau database.
//
// Pada Tahap 9, dependency diganti dari CourseApiService (konkret)
// menjadi CourseDataSource (kontrak/abstract class).
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  Future<void> updateCourse(int id, Course course) {
    return dataSource.updateCourse(id, course);
  }

  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}