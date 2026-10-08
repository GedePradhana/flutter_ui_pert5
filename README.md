# Course Explorer v2

Nama: I Gede Pradhana Subawa Deningrat
NIM: 2415051030

Aplikasi Flutter untuk menampilkan daftar course dengan state management
Provider dan architecture berlapis (Pertemuan 06).

## Arah Dependency

Screen/Widget -> CourseProvider -> CourseRepository -> CourseService -> JSON (assets)

UI tidak memanggil `rootBundle` atau `jsonDecode` secara langsung.

## Tanggung Jawab Setiap Folder

| Folder | Tanggung jawab |
|---|---|
| `lib/constants/` | Nilai tetap yang dipakai banyak screen (nama dan NIM mahasiswa). |
| `lib/models/` | Bentuk data. `Course` dan `Course.fromJson()` mengubah JSON menjadi object bertipe. |
| `lib/services/` | Akses sumber data mentah. `CourseService` membaca dan mem-parse file JSON di assets. Tidak mengandung UI. |
| `lib/repositories/` | Perantara antara state dan sumber data. `CourseRepository` menyembunyikan asal data dari Provider. |
| `lib/providers/` | State aplikasi dan logika perubahannya (`courses`, `isLoading`, `error`, `favorites`). Memanggil `notifyListeners()` saat state berubah. Tidak menyimpan `BuildContext`. |
| `lib/screens/` | Halaman penuh (Scaffold): Home, Courses, Favorites, Detail, Profile, Feedback, Counter, dan navigasi utama. |
| `lib/widgets/` | Komponen UI kecil yang dipakai di dalam screen: `CourseInteractionCard`, `FavoriteCountBadge`. |

`lib/main.dart` hanya merakit dependency (service, repository, provider) dan
menjalankan aplikasi.

## Hasil Audit (Tahap 16)

- `rootBundle` dan `jsonDecode` hanya ada di `CourseService`.
- `CourseService` tidak mengimpor `material.dart` dan tidak mengandung widget.
- `CourseProvider` tidak menyimpan `BuildContext`.
- Screen dan widget tidak mengimpor `services/` maupun `repositories/`.