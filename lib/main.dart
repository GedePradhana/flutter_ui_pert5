// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// ==================== COURSE EXPLORER v2 (TAHAP 14) ====================
// Arsitektur berlapis:
//   UI (screens/widgets) -> CourseProvider -> CourseRepository -> CourseService
//
// - models/        : Course (parsing JSON lewat Course.fromJson)
// - services/      : CourseService (membaca assets/data/student_data.json)
// - repositories/  : CourseRepository (perantara ke service)
// - providers/     : CourseProvider (courses, isLoading, error, favorites)
// - screens/       : halaman penuh (Home, Courses, Favorites, Detail, dst.)
// - widgets/       : komponen UI kecil (card, badge favorit)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_navigation_page.dart';
import 'services/course_service.dart';
import 'temp_http_test.dart';

void main() async {
  // ==================== TAHAP 2 ====================
  // Panggilan uji coba SEMENTARA. Tidak mempengaruhi tampilan
  // aplikasi sama sekali -- hasilnya cuma muncul di Debug Console.
  // WidgetsFlutterBinding perlu diinisialisasi dulu karena kita
  // memanggil kode async (http) sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();
  await runHttpGetTest();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(
        CourseRepository(CourseService()),
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