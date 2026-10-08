// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../providers/course_provider.dart';
import '../widgets/course_interaction_card.dart';
import 'course_detail_page.dart';

// TAHAP 13: hanya menampilkan course favorite. Tidak punya state
// sendiri; semuanya dibaca dari CourseProvider.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch -> rebuild setiap favorit berubah (dari screen mana pun).
    final favoriteCourses =
        context.watch<CourseProvider>().favoriteCourses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites - $studentId ${studentName.split(' ').first}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: favoriteCourses.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada course favorit.\n'
                  'Tap ikon hati di halaman Courses.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: favoriteCourses.map((course) {
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
              }).toList(),
            ),
    );
  }
}