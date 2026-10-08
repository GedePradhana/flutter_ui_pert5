// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';

// Badge jumlah favorite di AppBar. Dipisah supaya yang rebuild
// hanya widget kecil ini saat toggleFavorite() dipanggil.
class FavoriteCountBadge extends StatelessWidget {
  const FavoriteCountBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite),
        const SizedBox(width: 4),
        Text('${courseProvider.favorites.length}'),
      ],
    );
  }
}