// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';

// ==================== WORKSHEET 9 ====================
// Key global agar navigasi dan SnackBar bisa dipanggil dari LUAR widget:
// - listener sesi (auth) di main() untuk redirect ke LoginPage
// - SnackBar dari luar widget (dipakai notifikasi foreground pada Tahap 7)
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
