import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';

const String studentName = 'I Gede Pradhana Subawa Deningrat';
const String studentId = '2415051030';

// ==================== DATA COURSE ====================
// Data course diambil dari assets/data/student_data.json.
//
// TAHAP 9: proses membaca JSON ada di CourseService.
// TAHAP 10: CourseRepository menjadi perantara ke CourseService.
// TAHAP 11: CourseProvider yang memanggil repository dan menyimpan
// state async (courses, isLoading, error). UI hanya membaca state
// dari Provider, tidak lagi memanggil repository/service sendiri.
//
// Alur: UI -> CourseProvider -> CourseRepository -> CourseService

void main() {
  // ==================== TAHAP 6 + TAHAP 11 ====================
  // ChangeNotifierProvider menyediakan SATU instance CourseProvider
  // ke seluruh widget tree.
  //
  // TAHAP 11: CourseProvider menerima CourseRepository lewat
  // constructor, lalu loadCourses() dipanggil SEKALI saat provider
  // dibuat (lewat cascade `..`). Tidak dipanggil dari build(), jadi
  // data tidak dimuat berulang.
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

// ==================== MAIN NAVIGATION ====================
// TAHAP 7: status favorite dipegang CourseProvider.
// TAHAP 8: courses bertipe List<Course>.
// TAHAP 9-10: data dimuat lewat Repository -> Service.
//
// TAHAP 11: MainNavigationPage TIDAK lagi memuat data sendiri.
// initState(), _loadCourses(), repository, courses, isLoading, dan
// errorMessage lokal SUDAH DIHAPUS. Semua dipindah ke CourseProvider.
// Di sini cukup membaca isLoading dan error dari Provider.
//
// Catatan: dipakai context.select(), bukan context.watch(), supaya
// MainNavigationPage HANYA rebuild saat isLoading/error berubah,
// bukan setiap kali favorite di-toggle.

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= 600;

    // TAHAP 11: state async dibaca dari Provider.
    final isLoading = context.select<CourseProvider, bool>(
      (provider) => provider.isLoading,
    );
    final error = context.select<CourseProvider, String?>(
      (provider) => provider.error,
    );

    // 1) LOADING
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2) ERROR
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat data course:\n$error',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    // Aksi sekali-jalan -> read(), bukan watch().
                    context
                        .read<CourseProvider>()
                        .loadCourses();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3) SUCCESS
    // CoursesPage mengambil courses sendiri dari CourseProvider.
    final List<Widget> pages = [
      const HomePage(),
      const CoursesPage(),
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

// ==================== HOME PAGE ====================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.school,
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                'Learning Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'NIM: 2415051030',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Selamat datang di Course Explorer.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== COUNTER PAGE (TAHAP 4) ====================
// Halaman terpisah untuk demo ValueNotifier + ValueListenableBuilder.
// Dibuka lewat ikon flask di AppBar CoursesPage.

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final ValueNotifier<int> demoCounter = ValueNotifier<int>(0);

  @override
  void dispose() {
    demoCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo ValueNotifier'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'NIM: 2415051030',
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 24),

              Icon(
                Icons.science_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 8),

              const Text(
                'Tahap 4 — nilai ini berubah tanpa setState()',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      // Mengubah .value SAJA sudah cukup
                      // memicu listener. Tidak perlu
                      // setState() di sini.
                      demoCounter.value--;
                    },
                    icon: const Icon(Icons.remove),
                  ),

                  const SizedBox(width: 24),

                  ValueListenableBuilder<int>(
                    valueListenable: demoCounter,
                    builder: (context, value, child) {
                      return Container(
                        constraints: const BoxConstraints(
                          minWidth: 64,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 24),

                  IconButton.filledTonal(
                    onPressed: () {
                      demoCounter.value++;
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== COURSES PAGE ====================
// TAHAP 7: status favorite diambil dari CourseProvider.
// TAHAP 8: courses bertipe List<Course>.
//
// TAHAP 11: CoursesPage TIDAK lagi menerima `courses` lewat
// constructor. Daftar course dibaca dari CourseProvider memakai
// context.select(), jadi halaman ini hanya rebuild kalau LIST
// courses-nya berganti (mis. setelah loadCourses()), BUKAN setiap
// favorite di-toggle. Rebuild favorite tetap dibatasi di
// _FavoriteCountBadge dan Consumer pada card.

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  void showCourseMessage(
    BuildContext context,
    String title,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title dipilih'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TAHAP 11: courses berasal dari Provider.
    final List<Course> courses =
        context.select<CourseProvider, List<Course>>(
      (provider) => provider.courses,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses - $studentId ${studentName.split(' ').first}',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Ikon flask -> buka halaman demo ValueNotifier (Tahap 4)
          IconButton(
            tooltip: 'Demo ValueNotifier',
            icon: const Icon(Icons.science_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CounterPage(),
                ),
              );
            },
          ),

          // Badge jumlah favorite dipisah jadi widget kecil
          // sendiri supaya yang rebuild HANYA badge ini.
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: _FavoriteCountBadge(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...courses.map(
            (course) {
              return CourseInteractionCard(
                title: course.title,
                code: course.code,
                credits: course.credits,
                status: course.status,
                onTap: () {
                  showCourseMessage(
                    context,
                    course.title,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FeedbackPage(),
                ),
              );
            },
            child: const Text('Beri Feedback'),
          ),
        ],
      ),
    );
  }
}

// Widget kecil khusus untuk badge jumlah favorite di AppBar.
// build() di sini rebuild setiap kali notifyListeners() dipanggil
// di CourseProvider, tanpa membangun ulang seluruh CoursesPage.
class _FavoriteCountBadge extends StatelessWidget {
  const _FavoriteCountBadge();
// I Gede Pradhana Subawa Deningrat
// 2415051030
  @override
  Widget build(BuildContext context) {
    // watch() -> ikut dengar perubahan, memicu rebuild widget
    // KECIL INI SAJA setiap kali toggleFavorite() dipanggil.
    final courseProvider = context.watch<CourseProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite),
        const SizedBox(width: 4),
        Text('${courseProvider.favorites.length}'),
      ],
    );
  }
}

// ==================== INTERACTION CARD ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
// TAHAP 7: favorite & aksi toggle diambil langsung dari
// CourseProvider menggunakan `code` milik card ini.
// TAHAP 8: card menampilkan `status` dari model Course.
class CourseInteractionCard extends StatelessWidget {
  final String title;
  final String code;
  final int credits;
  final String status;
  final VoidCallback onTap;

  const CourseInteractionCard({
    super.key,
    required this.title,
    required this.code,
    required this.credits,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onDoubleTap: onTap,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$code • $credits SKS',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // TAHAP 8: field `status` dari model Course.
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Consumer membungkus HANYA ikon hati.
              Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  final isFavorite =
                      courseProvider.isFavorite(code);

                  return IconButton(
                    onPressed: () {
                      // read() -> aksi sekali-jalan tanpa listen.
                      context
                          .read<CourseProvider>()
                          .toggleFavorite(code);
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FEEDBACK PAGE ====================

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() =>
      _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController(
    text: studentName,
  );

  final TextEditingController nimController =
      TextEditingController(
    text: studentId,
  );

  final TextEditingController commentController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();
    super.dispose();
  }

  // ==================== TAHAP 14 ====================

  Future<void> submitForm() async {
    // Validasi form terlebih dahulu
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Dialog konfirmasi
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Feedback'),
          content: const Text(
            'Apakah kamu yakin ingin mengirim feedback ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );

    // Jika pengguna memilih Batal
    if (confirmed != true) {
      return;
    }

    // Loading feedback
    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    // SnackBar setelah proses berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Feedback berhasil dikirim!',
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Bersihkan komentar setelah berhasil
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                studentName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'NIM: 2415051030',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Form Feedback',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Masukkan komentar...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }

                  if (value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : submitForm,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Feedback',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE PAGE ====================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 55,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'NIM: 2415051030',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Pendidikan Teknik Informatika',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              const Text(
                'Undiksha',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}