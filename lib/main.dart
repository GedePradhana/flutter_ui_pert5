import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
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
      title: 'Learning Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Jika data tidak tersedia
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak tersedia'),
            );
          }

          final data = snapshot.data!;

          final student =
              data['student'] as Map<String, dynamic>;

          final courses =
              data['courses'] as List<dynamic>;

          final completedCourses = courses
              .where(
                (course) =>
                    (course as Map<String, dynamic>)['status'] ==
                    'done',
              )
              .length;

          final totalCredits = courses.fold<int>(
            0,
            (total, course) =>
                total +
                ((course as Map<String, dynamic>)['credits'] as int),
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile / Identity Card
                  ProfileCard(
                    name: student['name'] as String,
                    nim: student['nim'] as String,
                  ),

                  const SizedBox(height: 16),

                  // Summary Row
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Topik Selesai',
                        value: '$completedCourses',
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(width: 12),
                      SummaryCard(
                        title: 'Total SKS',
                        value: '$totalCredits',
                        icon: Icons.school,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Daftar Materi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // List materi
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course =
                          courses[index] as Map<String, dynamic>;

                      return CourseCard(
                        code: course['code'] as String,
                        title: course['title'] as String,
                        credits: course['credits'] as int,
                        status: course['status'] as String,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Reusable Profile Widget
class ProfileCard extends StatelessWidget {
  final String name;
  final String nim;

  const ProfileCard({
    super.key,
    required this.name,
    required this.nim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              child: Icon(
                Icons.person,
                size: 36,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('NIM: $nim'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Summary Widget
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Course Widget
class CourseCard extends StatelessWidget {
  final String code;
  final String title;
  final int credits;
  final String status;

  const CourseCard({
    super.key,
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == 'done';
    final bool isActive = status == 'active';

    final IconData statusIcon;

    if (isDone) {
      statusIcon = Icons.check_circle;
    } else if (isActive) {
      statusIcon = Icons.play_circle;
    } else {
      statusIcon = Icons.schedule;
    }

    final String statusText;

    if (isDone) {
      statusText = 'Selesai';
    } else if (isActive) {
      statusText = 'Aktif';
    } else {
      statusText = 'Direncanakan';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(statusIcon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$code • $credits SKS',
        ),
        trailing: Text(
          statusText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}