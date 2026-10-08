import 'package:flutter/foundation.dart';

// ==================== TAHAP 5 ====================
// ChangeNotifier dan notifyListeners()
// I Gede Pradhana Subawa Deningrat
// 2415051030
// Class ini menangani state favorites, menggantikan peran
// favoriteCodes yang sebelumnya ada di _MainNavigationPageState
// (Tahap 3). Tidak ada perubahan dari Tahap 5-6 — file ini
// SUDAH PAS untuk dipakai di Tahap 7 (watch/read/Consumer).
class CourseProvider extends ChangeNotifier {
  // Shared state: daftar kode course yang difavoritkan.
  // Masih Set<String>, sama seperti favoriteCodes di Tahap 3.
  final Set<String> favorites = {};

  // Method perubahan state. WAJIB memanggil notifyListeners()
  // setelah state berubah, supaya semua widget yang "mendengarkan"
  // CourseProvider ini ikut rebuild dengan nilai terbaru.
  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  // Helper kecil untuk mengecek status favorite satu course,
  // supaya UI tidak perlu mengakses .favorites.contains() langsung.
  bool isFavorite(String code) {
    return favorites.contains(code);
  }
}