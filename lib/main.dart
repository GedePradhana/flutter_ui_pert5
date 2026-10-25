// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// ==================== COURSE EXPLORER v2 (TAHAP 4, Pertemuan 7) ====================
// Arsitektur berlapis:
//   UI (screens/widgets) -> CourseProvider -> CourseRepository -> CourseApiService
//
// - models/        : Course (parsing JSON lewat Course.fromJson)
// - services/      : CourseApiService (REST API, menggantikan CourseService
//                    yang sebelumnya membaca assets/data/student_data.json)
// - repositories/  : CourseRepository (perantara ke service)
// - providers/     : CourseProvider (courses, isLoading, error, favorites)
// - screens/       : halaman penuh (Home, Courses, Favorites, Detail, dst.)
// - widgets/       : komponen UI kecil (card, badge favorit)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_navigation_page.dart';
import 'services/course_api_service.dart';

// Endpoint latihan (dummy, belum ada dari dosen). Ganti nilai ini
// kalau dosen sudah memberi endpoint resmi.
const String apiBaseUrl = 'https://jsonplaceholder.typicode.com';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(
        CourseRepository(CourseApiService(apiBaseUrl)),
      )..loadCourses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 50, 4, 255),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}