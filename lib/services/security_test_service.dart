// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== WORKSHEET 9: SECURITY TESTING (Praktik 6) ====================
// Dipakai HANYA saat debug (tombol ikon serangga di halaman detail course
// yang BUKAN milik user yang login). Menguji apakah RLS menolak operasi
// terhadap data milik user lain. Hasil: daftar baris [PASS]/[FAIL].
Future<List<String>> runSecurityTest({
  required int courseId,
  required String? ownerId,
}) async {
  final client = Supabase.instance.client;
  final logs = <String>[];

  // 1. UPDATE data user lain -> harus DENIED (0 baris berubah)
  try {
    final rows = await client
        .from('courses')
        .update({'title': 'DIUBAH OLEH USER LAIN'})
        .eq('id', courseId)
        .select();
    logs.add(rows.isEmpty
        ? '[PASS] UPDATE ditolak oleh RLS (0 baris berubah)'
        : '[FAIL] User ini berhasil mengubah data user lain!');
  } on PostgrestException catch (e) {
    logs.add('[PASS] UPDATE ditolak: ${e.code} - ${e.message}');
  }

  // 2. DELETE data user lain -> harus DENIED (0 baris terhapus)
  try {
    final rows =
        await client.from('courses').delete().eq('id', courseId).select();
    logs.add(rows.isEmpty
        ? '[PASS] DELETE ditolak oleh RLS (0 baris terhapus)'
        : '[FAIL] User ini berhasil menghapus data user lain!');
  } on PostgrestException catch (e) {
    logs.add('[PASS] DELETE ditolak: ${e.code} - ${e.message}');
  }

  // 3. INSERT atas nama user lain -> harus ERROR 42501
  if (ownerId != null) {
    try {
      await client.from('courses').insert({
        'code': 'SEC-${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Course palsu',
        'credits': 1,
        'status': 'planned',
        'owner_id': ownerId,
      });
      logs.add('[FAIL] INSERT atas nama user lain berhasil!');
    } on PostgrestException catch (e) {
      logs.add('[PASS] INSERT ditolak: ${e.code} - ${e.message}');
    }
  }

  return logs;
}
