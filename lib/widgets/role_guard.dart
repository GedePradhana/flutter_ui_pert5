// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';

// ==================== WORKSHEET 9: AUTHORIZATION PADA UI ====================
// Hanya menampilkan `child` jika role user termasuk dalam `allowed`.
// Menyembunyikan tombol hanya mengamankan UI, BUKAN database.
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allowed,
    required this.child,
  });

  final String role;
  final List<String> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return allowed.contains(role) ? child : const SizedBox.shrink();
  }
}
