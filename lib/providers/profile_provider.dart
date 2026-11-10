// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../services/profile_service.dart';

// ==================== WORKSHEET 9: STATE PROFILE / ROLE ====================
// Menyimpan profile user yang sedang login supaya semua screen bisa
// menentukan fitur yang boleh tampil (authorization pada UI).
// INGAT: ini hanya mengatur tampilan. Keamanan sebenarnya ada di
// RLS pada database.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);

  final ProfileService _service;

  UserProfile? profile;
  bool isLoading = false;
  String? error;

  String get role => profile?.role ?? '';

  /// Boleh menambah course: instructor dan admin.
  bool get canCreateCourse =>
      profile != null && (profile!.isInstructor || profile!.isAdmin);

  /// Boleh mengubah/menghapus course.
  /// Tahap 4: berdasarkan role saja. Kepemilikan (owner) ditambahkan di Tahap 5.
  bool canManageCourse(Course course) {
    final p = profile;
    if (p == null) return false;
    return p.isInstructor || p.isAdmin;
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      profile = await _service.getMyProfile();
      if (profile == null) {
        error = 'Profil belum ada. Jalankan SQL Bagian 1 (backfill profiles).';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dipanggil saat logout supaya data user lama tidak tersisa.
  void clear() {
    profile = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
