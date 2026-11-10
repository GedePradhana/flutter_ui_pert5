// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../app_keys.dart';
import '../firebase_options.dart';

// ==================== WORKSHEET 9: PUSH NOTIFICATION (FCM) ====================

/// FCM hanya dipakai di Android/iOS. Di web/desktop semua fungsi
/// notifikasi dilewati supaya aplikasi tetap bisa dijalankan.
bool get supportsPush =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Handler untuk kondisi BACKGROUND dan TERMINATED.
/// Harus berupa fungsi top-level (di luar class).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Diakses lewat getter agar FirebaseMessaging tidak tersentuh
  // pada platform yang tidak didukung.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Status permission terakhir (authorized / denied / notDetermined /
  /// provisional). Ditampilkan di ProfilePage sebagai bukti Tugas 6.
  final ValueNotifier<String> permissionStatus =
      ValueNotifier<String>('belum diminta');

  /// Dipanggil saat notifikasi ditekan. Isinya data kustom notifikasi
  /// (mis. {'course_id': '3'}). Diatur oleh MainNavigationPage.
  void Function(Map<String, dynamic> data)? onNotificationTap;

  String? _currentToken;
  bool _listening = false;

  // ---------- Praktik 8: permission ----------
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final status = settings.authorizationStatus;
    permissionStatus.value = status.name;
    debugPrint('Notification permission: ${status.name}');
    return status;
  }

  // ---------- Praktik 9: token ----------
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    _currentToken = token;
    debugPrint('FCM Token: $token');
    return token;
  }

  /// Menyimpan token ke tabel device_tokens (Device Registration).
  /// Token TIDAK ditulis di source code dan TIDAK di-commit.
  Future<void> saveTokenToSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      // Tidak boleh membuat aplikasi crash hanya karena gagal simpan token.
      debugPrint('Gagal menyimpan token: $e');
    }
  }

  /// Dipanggil SEBELUM logout: hapus token perangkat ini dari akun yang
  /// sedang login, supaya notifikasi akun lama tidak sampai ke perangkat
  /// yang kemudian dipakai akun lain.
  Future<void> unregisterDevice() async {
    if (!supportsPush) return;
    try {
      final token = _currentToken ?? await _messaging.getToken();
      if (token == null) return;
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('token', token);
    } catch (e) {
      debugPrint('Gagal menghapus token perangkat: $e');
    }
  }

  // ---------- Praktik 8 + 9 + 10 ----------
  /// Dipanggil setiap user masuk ke aplikasi (setelah login / session
  /// dipulihkan). Aman dipanggil berulang: listener hanya dipasang sekali.
  Future<void> init() async {
    if (!supportsPush) return;

    try {
      final status = await requestPermission();

      // iOS: tampilkan banner saat aplikasi di foreground.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _startListeners();

      if (status == AuthorizationStatus.denied) {
        debugPrint('Permission ditolak: token tidak didaftarkan.');
        return;
      }

      final token = await getToken();
      if (token != null) await saveTokenToSupabase(token);
    } catch (e) {
      debugPrint('Inisialisasi notifikasi gagal: $e');
    }
  }

  Future<void> _startListeners() async {
    if (_listening) return;
    _listening = true;

    // Token dapat berubah, sehingga perubahannya perlu didengarkan.
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui');
      _currentToken = newToken;
      saveTokenToSupabase(newToken);
    });

    // FOREGROUND: aplikasi sedang terbuka.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('title: ${message.notification?.title}');
      debugPrint('body : ${message.notification?.body}');
      debugPrint('data : ${message.data}');

      // Android tidak menampilkan notifikasi sistem saat foreground,
      // jadi tampilkan sendiri di dalam aplikasi.
      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('$title\n$body')),
      );
    });

    // ---------- Bonus: notifikasi ditekan ----------
    // Aplikasi BACKGROUND lalu dibuka dari notifikasi.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onNotificationTap?.call(message.data);
    });

    // Aplikasi TERMINATED lalu dibuka dari notifikasi.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) onNotificationTap?.call(initial.data);
  }
}
