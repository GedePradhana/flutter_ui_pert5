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
// ==================== TAHAP 10 .====================
// Supabase.initialize() dipanggil sebelum runApp(), supaya client
// Supabase siap dipakai sebelum widget tree dibangun.
//
// ==================== TAHAP 12 ====================
// Sumber data diganti dari CourseApiService (REST dummy) ke
// CourseSupabaseService (tabel `courses` di Supabase). Hanya SATU
// baris perakitan yang berubah; Repository, Provider, dan UI tetap.
//
// ==================== TAHAP 16: COURSE DATA MANAGER ====================
// Data source aktif dipilih HANYA di main() lewat variabel
// `dataSource`. Untuk berpindah ke REST, ganti satu baris itu saja.
//
// ==================== WORKSHEET 9: AUTH + ROLE + PUSH ====================
// - Check Session : home = MainNavigationPage jika sudah login, selain itu
//                   LoginPage (session dipulihkan Supabase.initialize()).
// - Listener sesi : event signedOut (logout / sesi berakhir) -> data
//                   provider dibersihkan dan kembali ke LoginPage.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_keys.dart';
import 'constants/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/login_page.dart';
import 'screens/main_navigation_page.dart';
import 'services/auth_service.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Perakitan: data source -> repository -> provider.
  // Data source aktif: Supabase.
  // (untuk REST: CourseApiService(apiBaseUrl))
  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);

  // Provider dibuat di sini (bukan di dalam widget) supaya listener sesi
  // di bawah bisa membersihkan datanya saat logout.
  // Data course TIDAK dimuat di sini: RLS mewajibkan user login, jadi
  // pemuatan dilakukan MainNavigationPage setelah user masuk.
  final courseProvider = CourseProvider(repository);

  // Mendengarkan perubahan session: berguna saat logout, atau saat
  // session berakhir / logout dari tempat lain.
  AuthService.instance.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');
    if (data.event == AuthChangeEvent.signedOut) {
      courseProvider.reset();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  });

  runApp(
    ChangeNotifierProvider<CourseProvider>.value(
      value: courseProvider,
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
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
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
      // Check Session -> Home / Login
      home: AuthService.instance.isLoggedIn
          ? const MainNavigationPage()
          : const LoginPage(),
    );
  }
}