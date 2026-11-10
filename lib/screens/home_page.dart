// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../providers/profile_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _roleLabel(String role) {
    switch (role) {
      case 'instructor':
        return 'Instructor';
      case 'admin':
        return 'Admin';
      case 'student':
        return 'Student';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    // WORKSHEET 9: tampilkan identitas user yang sedang login.
    final profile = context.watch<ProfileProvider>().profile;

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
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                profile == null
                    ? 'Selamat datang di Course Explorer.'
                    : 'Selamat datang, '
                        '${profile.name.isEmpty ? profile.email : profile.name}.',
                textAlign: TextAlign.center,
              ),
              if (profile != null) ...[
                const SizedBox(height: 8),
                Chip(
                  avatar: const Icon(Icons.badge, size: 18),
                  label: Text('Role: ${_roleLabel(profile.role)}'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
