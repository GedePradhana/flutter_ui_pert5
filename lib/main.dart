// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// ==================== COURSE EXPLORER v2 (TAHAP 4, Pertemuan 7) ====================
// Arsitektur berlapis:
//   UI (screens/widgets) -> CourseProvider -> CourseRepository -> CourseDataSource
//
// - models/        : Course (parsing JSON lewat Course.fromJson)
// - services/      : CourseDataSource (kontrak) dengan implementasi
//                    CourseApiService (REST) dan CourseSupabaseService
//                    (database Supabase)
// - repositories/  : CourseRepository (perantara ke data source)
// - providers/     : CourseProvider (courses, isLoading, error, favorites)
// - screens/       : halaman penuh (Home, Courses, Favorites, Detail, dst.)
// - widgets/       : komponen UI kecil (card, badge favorit)
//
// ==================== TAHAP 10 ====================
// Supabase.initialize() dipanggil sebelum runApp(), supaya client
// Supabase siap dipakai sebelum widget tree dibangun.
//
// ==================== TAHAP 12 ====================
// Sumber data diganti dari CourseApiService (REST dummy) ke
// CourseSupabaseService (tabel `courses` di Supabase). Hanya SATU
// baris perakitan yang berubah; Repository, Provider, dan UI tetap.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_navigation_page.dart';
import 'services/course_supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Perakitan: service -> repository -> provider.
  // Sebelumnya: CourseRepository(CourseApiService(apiBaseUrl))
  final repository = CourseRepository(CourseSupabaseService());

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository)..loadCourses(),
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