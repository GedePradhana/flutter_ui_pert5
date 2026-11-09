// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

// ==================== WORKSHEET 9: AUTHENTICATION ====================
// AuthService membungkus Supabase Auth. Screen cukup memanggil
// register/login/logout dan menangkap AppException; screen tidak perlu
// mengimpor supabase_flutter (konsisten dengan arsitektur berlapis).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const Duration _timeout = Duration(seconds: 15);

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  // "Check Session": Supabase memulihkan session dari penyimpanan
  // perangkat saat Supabase.initialize() dipanggil.
  bool get isLoggedIn => currentSession != null;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// true  = langsung login (Confirm email nonaktif).
  /// false = akun dibuat, tetapi user harus konfirmasi email dulu.
  Future<bool> register({
    required String email,
    required String password,
    String name = '',
    String role = 'student', // 'student' atau 'instructor'
  }) async {
    try {
      final res = await _client.auth
          .signUp(
            email: email,
            password: password,
            // dibaca oleh trigger handle_new_user di database
            data: {'name': name, 'role': role},
          )
          .timeout(_timeout);
      return res.session != null;
    } on AuthException catch (e) {
      throw _fromAuth(e);
    } catch (e) {
      throw AppException.wrap(e);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth
          .signInWithPassword(email: email, password: password)
          .timeout(_timeout);
    } on AuthException catch (e) {
      // Password salah / email belum terdaftar -> "Invalid login credentials"
      throw _fromAuth(e);
    } catch (e) {
      throw AppException.wrap(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw _fromAuth(e);
    } catch (e) {
      throw AppException.wrap(e);
    }
  }

  AppException _fromAuth(AuthException e) {
    return AppException(
      AppErrorType.unauthorized,
      e.message,
      statusCode: int.tryParse(e.statusCode ?? ''),
    );
  }
}
