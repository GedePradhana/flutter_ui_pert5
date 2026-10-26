// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_page.dart';
import '../constants/student_info.dart';
import '../providers/course_provider.dart';
import '../widgets/course_interaction_card.dart';
import '../widgets/error_view.dart';
import '../widgets/favorite_count_badge.dart';
import 'add_course_page.dart';
import 'counter_page.dart';
import 'feedback_page.dart';

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
    // ==================== TAHAP 5 ====================
    // watch() di sini (bukan select) karena kita butuh BEBERAPA
    // field sekaligus dari provider (isLoading, error, courses)
    // untuk menentukan state mana yang ditampilkan.
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses - $studentId ${studentName.split(' ').first}',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // ==================== TAHAP 16 ====================
          // Refresh manual: memuat ulang data dari database.
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : provider.loadCourses,
          ),
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

          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: FavoriteCountBadge(),
          ),
        ],
      ),
      body: _buildBody(context, provider),
      // ==================== TAHAP 6 ====================
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Course',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCoursePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==================== TAHAP 5 ====================
  // Loading -> Error -> Empty -> Success, urutan pengecekan ini
  // penting: cek loading dulu, baru error, baru empty, baru data.
  Widget _buildBody(BuildContext context, CourseProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    if (provider.courses.isEmpty) {
      return const Center(
        child: Text('Data course belum tersedia'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...provider.courses.map(
          (course) {
            return CourseInteractionCard(
              title: course.title,
              code: course.code,
              credits: course.credits,
              status: course.status,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CourseDetailPage(course: course),
                  ),
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
                builder: (context) => const FeedbackPage(),
              ),
            );
          },
          child: const Text('Beri Feedback'),
        ),
      ],
    );
  }
}