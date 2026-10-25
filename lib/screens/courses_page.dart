// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'course_detail_page.dart';
import '../constants/student_info.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_interaction_card.dart';
import '../widgets/favorite_count_badge.dart';
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