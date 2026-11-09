// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';

import '../services/app_exception.dart';
import '../services/auth_service.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';

// ==================== WORKSHEET 9: LOGIN ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await AuthService.instance.login(
        email: _emailC.text.trim(),
        password: _passC.text,
      );
      if (!mounted) return;
      // Pesan sukses; SnackBar tetap tampil di halaman berikutnya.
      _showMessage('Login berhasil. Selamat datang!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        (route) => false,
      );
    } on AppException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Terjadi kesalahan. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Course Explorer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.school, size: 72),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        ),
                child: const Text('Belum punya akun? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
