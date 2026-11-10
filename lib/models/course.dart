// ==================== TAHAP 3 (Pertemuan 7) ====================
// Model Course: mengubah Map<String, dynamic> dari JSON menjadi
// object bertipe jelas. Parsing JSON dipusatkan di Course.fromJson(),
// sehingga UI tidak perlu lagi mengakses key string secara manual.
// I Gede Pradhana Subawa Deningrat
// 2415051030
//
// Perubahan dari Pertemuan 6:
// - Ditambahkan field 'id' (nullable), karena data dari REST API
//   / database biasanya punya primary key, sedangkan data lokal
//   (student_data.json) tidak selalu punya id.
// - Ditambahkan toJson(), dipakai nanti saat mengirim data lewat
//   POST/PUT (Tahap 6-7) dan ke Supabase (Tahap 13-14).
// - Default status diubah ke 'planned' (bukan 'Aktif'), supaya
//   konsisten dengan nilai status lain yang dipakai di aplikasi
//   ('done', 'active', 'planned') dan dengan contoh di worksheet.
class Course {
  final int? id;
  // WORKSHEET 9: id pemilik (auth.users.id), dipakai untuk authorization UI
  // dan RLS. Nullable karena data REST/lokal tidak punya owner.
  final String? ownerId;
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    this.id,
    this.ownerId,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      ownerId: json['owner_id'] as String?,
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      // Field 'status' diberi nilai default supaya aplikasi tidak
      // crash jika sumber data belum memiliki key 'status'.
      status: (json['status'] as String?) ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'credits': credits,
        'status': status,
      };
}