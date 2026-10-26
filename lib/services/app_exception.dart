import 'dart:async';

// ==================== TAHAP 17 ====================
// AppException: satu jenis error untuk seluruh aplikasi. Service
// (REST maupun Supabase) menerjemahkan error teknis (status HTTP,
// kode PostgreSQL, TypeError, tidak ada internet) menjadi pesan yang
// informatif. Provider dan screen cukup menampilkan `message`
// tanpa perlu tahu error aslinya.
// I Gede Pradhana Subawa Deningrat
// 2415051030
enum AppErrorType {
  network,
  timeout,
  notFound,
  badRequest,
  unauthorized,
  forbidden,
  conflict,
  validation,
  server,
  parsing,
  unknown,
}

class AppException implements Exception {
  const AppException(this.type, this.message, {this.statusCode});

  final AppErrorType type;
  final String message;
  final int? statusCode;

  // Kasus A: HTTP 404 dan status error lain dari REST API.
  factory AppException.fromStatus(int status) {
    switch (status) {
      case 400:
        return AppException(
          AppErrorType.badRequest,
          'Data yang dikirim tidak valid (400 Bad Request).',
          statusCode: status,
        );
      case 401:
        return AppException(
          AppErrorType.unauthorized,
          'Belum terautentikasi atau API key tidak valid (401).',
          statusCode: status,
        );
      case 403:
        return AppException(
          AppErrorType.forbidden,
          'Anda tidak memiliki izin untuk aksi ini (403 Forbidden).',
          statusCode: status,
        );
      case 404:
        return AppException(
          AppErrorType.notFound,
          'Endpoint atau data tidak ditemukan (404 Not Found). '
          'Periksa kembali alamat endpoint.',
          statusCode: status,
        );
      default:
        if (status >= 500) {
          return AppException(
            AppErrorType.server,
            'Server sedang bermasalah ($status). Coba lagi beberapa saat.',
            statusCode: status,
          );
        }
        return AppException(
          AppErrorType.unknown,
          'Permintaan gagal dengan status $status.',
          statusCode: status,
        );
    }
  }

  // Kasus B: tidak ada internet / server tidak terjangkau.
  factory AppException.network() => const AppException(
        AppErrorType.network,
        'Tidak ada koneksi internet atau server tidak dapat dijangkau. '
        'Periksa koneksi, lalu tekan Retry.',
      );

  factory AppException.timeout() => const AppException(
        AppErrorType.timeout,
        'Server terlalu lama merespons. Periksa koneksi, lalu tekan Retry.',
      );

  // Kasus C: bentuk JSON tidak sesuai model (key hilang / tipe salah).
  factory AppException.parsing() => const AppException(
        AppErrorType.parsing,
        'Format data dari server tidak sesuai dengan model aplikasi '
        '(key JSON atau tipe data berbeda).',
      );

  // Menerjemahkan error umum yang tidak spesifik ke satu library.
  // Error khusus library (http, supabase) ditangani lebih dulu di
  // service masing-masing.
  factory AppException.wrap(Object error) {
    if (error is AppException) return error;
    if (error is TimeoutException) return AppException.timeout();
    if (error is TypeError || error is FormatException) {
      return AppException.parsing();
    }

    // SocketException tidak di-import langsung (dart:io tidak
    // tersedia di web), jadi dikenali lewat teks error-nya.
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('Failed to fetch') ||
        text.contains('ClientException') ||
        text.contains('Network is unreachable')) {
      return AppException.network();
    }

    return AppException(AppErrorType.unknown, 'Terjadi kesalahan: $text');
  }

  // toString() mengembalikan pesan bersih, sehingga
  // provider.error = e.toString() dan SnackBar '$e' tidak lagi
  // menampilkan awalan "Exception: ".
  @override
  String toString() => message;
}