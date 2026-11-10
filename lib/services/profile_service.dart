// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

// ==================== WORKSHEET 9: ROLE PENGGUNA ====================
// Role: student (hanya melihat), instructor (pemilik course), admin.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role; // student | instructor | admin

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isStudent => role == 'student';
  bool get isInstructor => role == 'instructor';
  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        email: (m['email'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        role: (m['role'] ?? 'student') as String,
      );
}

class ProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Mengambil profile (termasuk role) milik user yang sedang login.
  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser; // currentUser
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      return data == null ? null : UserProfile.fromMap(data); // currentUserRole
    } on PostgrestException catch (e) {
      throw AppException(
        AppErrorType.unknown,
        'Gagal memuat profil: ${e.message} (kode ${e.code}).',
      );
    } catch (e) {
      throw AppException.wrap(e);
    }
  }
}
