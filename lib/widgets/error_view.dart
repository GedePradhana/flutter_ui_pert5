import 'package:flutter/material.dart';

// ==================== TAHAP 5 ====================
// Widget generik untuk menampilkan pesan error + tombol Retry.
// Dipakai di CoursesPage (dan screen lain yang butuh pola serupa)
// supaya UI error tidak ditulis ulang di banyak tempat.
// I Gede Pradhana Subawa Deningrat
// 2415051030
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}