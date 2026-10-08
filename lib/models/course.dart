// ==================== TAHAP 8 ====================
// Model Course: mengubah Map<String, dynamic> dari JSON menjadi
// object bertipe jelas. Parsing JSON dipusatkan di Course.fromJson(),
// sehingga UI tidak perlu lagi mengakses key string seperti
// I Gede Pradhana Subawa Deningrat
// 2415051030
class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      // Field 'status' diberi nilai default supaya aplikasi tidak
      // crash jika student_data.json belum memiliki key 'status'.
      status: (json['status'] as String?) ?? 'Aktif',
    );
  }
}