// ==================== TAHAP 2 ====================
// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// File ini SEMENTARA. Isinya cuma untuk mencoba package http dan
// memahami pola request-response, SEBELUM kodenya dipindah ke
// CourseApiService pada Tahap 4. File ini tidak dipanggil oleh
// screen/widget mana pun secara permanen -- dipanggil sekali lewat
// main() untuk diuji, lihat hasilnya di Debug Console, lalu boleh
// dihapus/diabaikan setelah Tahap 4 selesai.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Endpoint latihan (dummy, belum ada dari dosen).
// Operasi write ke endpoint ini hanya disimulasikan, tidak persisten.
const String apiUrl = 'https://jsonplaceholder.typicode.com/todos';

// Kalau mau sengaja lihat error (sesuai instruksi worksheet),
// ganti sementara jadi salah satu baris di bawah ini saat memanggil
// fetchCoursesTest(), lalu kembalikan lagi ke apiUrl yang benar:
//
//   await fetchCoursesTest(url: 'https://jsonplaceholder.typicode.com/todosxxx');
//
// Endpoint yang salah akan membuat response.statusCode menjadi 404,
// sehingga masuk ke blok throw Exception di bawah.

Future<List<dynamic>> fetchCoursesTest({String url = apiUrl}) async {
  final response = await http.get(Uri.parse(url));

  // WAJIB cek status code dulu sebelum memproses body-nya.
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }

  throw Exception('HTTP ${response.statusCode}');
}

// Dipanggil sekali dari main() untuk menguji, lihat hasilnya
// di Debug Console (bukan di UI dulu -- itu baru Tahap 5).
Future<void> runHttpGetTest() async {
  try {
    final data = await fetchCoursesTest();

    debugPrint(
      '[Tahap 2] 2415051030 - I Gede Pradhana Subawa Deningrat: '
      'berhasil GET, jumlah item = ${data.length}',
    );

    // Tampilkan 1 item pertama sebagai contoh bentuk datanya.
    if (data.isNotEmpty) {
      debugPrint('[Tahap 2] Contoh item pertama: ${data.first}');
    }
  } catch (e) {
    debugPrint('[Tahap 2] GAGAL fetch: $e');
  }
}