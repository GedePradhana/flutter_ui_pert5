# Course Data Manager (pengembangan Course Explorer v2)

Nama: I Gede Pradhana Subawa Deningrat
NIM: 2415051030
Kelas: PTI 5C

Aplikasi Flutter untuk mengelola data course (Create, Read, Update, Delete)
yang tersimpan di database Supabase (PostgreSQL). Aplikasi ini adalah
pengembangan dari Course Explorer v2 (Pertemuan 5-6) dan tetap memiliki
responsive navigation, halaman detail, dan favorites.

## Fitur

- Menampilkan daftar course dari Supabase (SELECT)
- Tambah course lewat form dengan validasi (INSERT)
- Edit course dari halaman detail; field `code` read-only (UPDATE)
- Hapus course dengan dialog konfirmasi (DELETE)
- State loading, empty, error + tombol Retry, dan tombol Refresh
- SnackBar untuk hasil operasi berhasil/gagal
- Favorites memakai `code` sebagai kunci, konsisten di Courses, Detail, dan Favorites
- Navigasi responsif: NavigationBar (layar sempit) dan NavigationRail (layar lebar)

## Backend yang Digunakan

Supabase (tabel `courses`). Latihan REST Tahap 1-9 memakai JSONPlaceholder
(`https://jsonplaceholder.typicode.com/todos`), diakses lewat `CourseApiService`.

Tabel `courses`:

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint identity | Primary key |
| code | text | Kode course |
| title | text | Judul course |
| credits | int | SKS, CHECK > 0 |
| status | text | planned / active / done (CHECK) |
| created_at | timestamptz | default now() |

RLS aktif dengan policy permisif untuk role `anon` (khusus laboratorium
praktikum, bukan pola produksi). Aplikasi hanya memakai publishable/anon key;
service_role key TIDAK digunakan.

## Arsitektur

```
UI (screens/widgets) -> CourseProvider -> CourseRepository -> CourseDataSource
                                                               |-- CourseSupabaseService (aktif)
                                                               `-- CourseApiService (REST, cadangan)
```

Data source aktif dipilih hanya di `lib/main.dart`:

```dart
final CourseDataSource dataSource = CourseSupabaseService();
// untuk REST: CourseApiService(apiBaseUrl)
```

## Struktur Folder

| Folder | Tanggung jawab |
|---|---|
| `lib/constants/` | Nama/NIM mahasiswa dan konfigurasi Supabase (URL + anon key). |
| `lib/models/` | `Course` dengan `fromJson()` dan `toJson()`. |
| `lib/services/` | `CourseDataSource` (kontrak), `CourseSupabaseService`, `CourseApiService`. |
| `lib/repositories/` | `CourseRepository`, perantara provider dan data source. |
| `lib/providers/` | `CourseProvider`: courses, isLoading, isSaving, error, favorites. |
| `lib/screens/` | Home, Courses, Favorites, Detail, Add/Edit Course, Profile, dll. |
| `lib/widgets/` | `CourseInteractionCard`, `ErrorView`, `FavoriteCountBadge`. |

## Cara Menjalankan

1. Pastikan Flutter SDK terpasang.
2. `flutter pub get`
3. Isi `lib/constants/supabase_config.dart` dengan Project URL dan
   publishable/anon key milik project Supabase Anda.
4. Buat tabel `courses` di Supabase sesuai skema di atas, aktifkan RLS dan
   buat policy, lalu `GRANT SELECT, INSERT, UPDATE, DELETE ON public.courses TO anon;`
5. `flutter run`

## Hasil Audit

- Screen dan provider tidak mengimpor `package:http` maupun `supabase_flutter`.
- Hanya `CourseSupabaseService` dan `CourseApiService` yang berkomunikasi dengan backend.
- `CourseProvider` tidak menyimpan `BuildContext`.
- Tidak ada service_role key di source code.

## Catatan Endpoint REST (Tahap 1)

Karena endpoint resmi dari dosen belum diberikan, latihan Tahap 1-9
menggunakan API dummy publik **JSONPlaceholder**.

- Endpoint: `https://jsonplaceholder.typicode.com/todos`
- HTTP Method: `GET`
- Status code: `200 OK`
- Resource: `todos` (200 item data dummy)

Contoh satu item response (array of object):

```json
{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

Minimal 4 field JSON yang ditemukan:

| Field | Tipe | Keterangan |
|---|---|---|
| `userId` | int | ID pemilik todo |
| `id` | int | ID unik todo (primary key) |
| `title` | string | Judul todo |
| `completed` | bool | Status selesai atau belum |

Catatan penyesuaian ke domain Course: karena JSONPlaceholder tidak
punya field `code`/`credits`/`status` seperti model `Course`, field API
dipetakan pada Tahap 3 sesuai arahan worksheet: `id` -> `id`,
`title` -> `title`, `userId` -> dipetakan sementara ke `credits`,
`completed` -> dipetakan ke `status` (`true` -> `done`,
`false` -> `planned`). Endpoint ini hanya dipakai untuk latihan REST
(Tahap 1-9); sumber data final aplikasi adalah Supabase (Tahap 10-16).