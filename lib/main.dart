import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'I Gede Pradhana Subawa Deningrat';
const String studentId = '2415051030';

// ==================== DATA COURSE ====================
// Data course TIDAK lagi hardcoded di sini. Data diambil dari
// assets/data/student_data.json (lihat loadCourseData di bawah).
// Field 'favorite' tetap tidak ada di sumber data, karena status
// favorite dimiliki oleh MainNavigationPage (single source of truth).

// Membaca dan mem-parsing file JSON di folder data.
// Catatan: langkah ini nantinya akan dipisah ke CourseService
// (Tahap 9) dan CourseRepository (Tahap 10) agar tidak dipanggil
// langsung dari UI.
Future<List<Map<String, dynamic>>> loadCourseData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final list = data['courses'] as List<dynamic>;

  return list.cast<Map<String, dynamic>>();
}

void main() {
  runApp(const MyApp());
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
// TAHAP 3: LIFTING STATE UP
// State favorite dipindahkan ke MainNavigationPage karena
// ini adalah ancestor terdekat dari HomePage dan CoursesPage
// (dua widget yang sama-sama membutuhkan data favorite).
//
// MainNavigationPage juga menjadi tempat courses dimuat dari
// JSON, supaya hanya ada SATU proses loading untuk seluruh app.

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int currentIndex = 0;

  // SINGLE SOURCE OF TRUTH
  // Hanya ada SATU tempat penyimpanan favorite di seluruh aplikasi.
  // Child tidak boleh menyimpan salinan sendiri.
  final Set<String> favoriteCodes = {};

  // Data course hasil load dari JSON, dan status loading-nya.
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final result = await loadCourseData();

      if (!mounted) {
        return;
      }

      setState(() {
        courses = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Aksi perubahan state. Method ini dikirim ke child
  // sebagai callback.
  void toggleFavorite(String code) {
    setState(() {
      if (favoriteCodes.contains(code)) {
        favoriteCodes.remove(code);
      } else {
        favoriteCodes.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width >= 600;

    // Selama data belum selesai dimuat, tampilkan loading
    // penuh layar terlebih dahulu.
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat data course:\n$errorMessage',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // pages dibuat di dalam build() karena sekarang
    // bergantung pada state (favoriteCodes dan courses).
    final List<Widget> pages = [
      const HomePage(),
      CoursesPage(
        courses: courses,
        favoriteCodes: favoriteCodes,
        onToggleFavorite: toggleFavorite,
      ),
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
// Halaman sambutan sederhana. Ringkasan favorite sudah
// dipindahkan ke AppBar CoursesPage (ikon hati + angka),
// dan demo ValueNotifier dipindahkan ke CounterPage tersendiri
// (dibuka lewat ikon flask di AppBar CoursesPage).

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
//
// Perbandingan dengan setState():
// - setState() -> membangun ulang seluruh build() milik widget
//   yang memanggilnya.
// - ValueNotifier + ValueListenableBuilder -> hanya widget di
//   dalam builder yang rebuild saat value berubah; bagian lain
//   dari halaman ini (judul, ikon, penjelasan) TIDAK ikut rebuild.

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
// WIDGET KE-2 yang memakai state favorite.
// StatelessWidget karena tidak lagi memiliki state sendiri:
//  - data masuk lewat constructor (courses, favoriteCodes)
//  - aksi keluar lewat callback (onToggleFavorite)
//
// AppBar menampilkan ringkasan favorite (ikon hati + angka) dan
// ikon flask untuk membuka CounterPage (demo Tahap 4).

class CoursesPage extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favoriteCodes;
  final void Function(String code) onToggleFavorite;

  const CoursesPage({
    super.key,
    required this.courses,
    required this.favoriteCodes,
    required this.onToggleFavorite,
  });

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

          // Ringkasan favorite (single source of truth dari
          // MainNavigationPage). Nilai ini harus selalu sama
          // dengan jumlah hati yang aktif di daftar di bawah.
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite),
                const SizedBox(width: 4),
                Text('${favoriteCodes.length}'),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...courses.map(
            (course) {
              final code = course['code'] as String;

              return CourseInteractionCard(
                title: course['title'] as String,
                code: code,
                credits: course['credits'] as int,
                // data dari parent
                favorite: favoriteCodes.contains(code),
                onTap: () {
                  showCourseMessage(
                    context,
                    course['title'] as String,
                  );
                },
                // I Gede Pradhana Subawa Deningrat
                // 2415051030
                // aksi dikirim balik ke parent lewat callback
                onFavorite: () {
                  onToggleFavorite(code);
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

// ==================== INTERACTION CARD ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
class CourseInteractionCard extends StatelessWidget {
  final String title;
  final String code;
  final int credits;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const CourseInteractionCard({
    super.key,
    required this.title,
    required this.code,
    required this.credits,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
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
                    ],
                  ),
                ),
              ),

              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  favorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favorite ? Colors.red : null,
                ),
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