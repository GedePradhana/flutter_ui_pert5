// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../providers/profile_provider.dart';
import 'courses_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

// ==================== TAHAP 5 (Pertemuan 7) ====================
// Pengecekan isLoading/error di level navigasi (yang sebelumnya ada
// di sini sejak Pertemuan 6) DIHAPUS. Alasannya: itu memblokir
// SELURUH aplikasi (termasuk tab Home dan Profile yang tidak
// butuh data course) hanya karena course gagal dimuat, dan membuat
// ErrorView yang baru dibuat di CoursesPage tidak pernah sempat
// tampil (ketimpa duluan oleh pengecekan di sini).
//
// Sekarang setiap tab bertanggung jawab atas state-nya sendiri:
// CoursesPage menangani loading/error/empty/success miliknya
// sendiri lewat CourseProvider, FavoritesPage menampilkan pesan
// "belum ada favorit" kalau courses masih kosong. Home dan Profile
// tidak terpengaruh sama sekali oleh status course.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int currentIndex = 0;

  // ==================== WORKSHEET 9 ====================
  // Setelah user masuk (login baru ATAU session dipulihkan), muat profile
  // + role dan data course.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().load();
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= 600;

    final List<Widget> pages = [
      const HomePage(),
      const CoursesPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: Text('Courses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          Expanded(
            child: pages[currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: !isWide
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Courses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}