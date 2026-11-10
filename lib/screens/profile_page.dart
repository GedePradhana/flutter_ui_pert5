// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_info.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ==================== WORKSHEET 9: LOGOUT ====================
  // signOut() menghapus session; listener onAuthStateChange di main()
  // lalu membersihkan data provider dan mengarahkan ke LoginPage.
  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
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
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pendidikan Teknik Informatika',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Undiksha',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Divider(),

              // ---------- Akun yang sedang login (Tugas 3) ----------
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else if (profile == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.error ?? 'Gagal memuat profil',
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nama'),
                  subtitle: Text(profile.name.isEmpty ? '-' : profile.name),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(profile.email),
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Role'),
                  subtitle: Text(profile.role),
                ),
              ],

              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
