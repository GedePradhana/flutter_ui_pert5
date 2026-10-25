# Course Explorer v2

Nama: I Gede Pradhana Subawa Deningrat
NIM: 2415051030

Aplikasi Flutter untuk menampilkan daftar course dengan state management
Provider dan architecture berlapis (Pertemuan 06).

## Arah Dependency

Screen/Widget -> CourseProvider -> CourseRepository -> CourseService -> JSON (assets)

UI tidak memanggil `rootBundle` atau `jsonDecode` secara langsung.

## Tanggung Jawab Setiap Folder

| Folder | Tanggung jawab |.
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

## Pertemuan 7 — REST API, Backend Services & Database Integration

### Tahap 1. Endpoint REST yang Digunakan

Karena endpoint resmi dari dosen belum diberikan, latihan Tahap 1–9
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
punya field `code`/`credits`/`status` seperti model `Course` di app ini,
field API akan dipetakan pada Tahap 3 (`Course.fromJson`) sesuai arahan
worksheet ("sesuaikan nama field dengan JSON API yang digunakan"):
`id` → `id`, `title` → `title`, `userId` → dipetakan sementara ke
`credits`, `completed` → dipetakan ke `status` (`true` → `done`,
`false` → `planned`). Endpoint ini hanya dipakai untuk latihan REST
(Tahap 1–9); sumber data final aplikasi tetap Supabase (Tahap 10–16).


### Hasil Audit (Tahap 16)

- `rootBundle` dan `jsonDecode` hanya ada di `CourseService`.
- `CourseService` tidak mengimpor `material.dart` dan tidak mengandung widget.
- `CourseProvider` tidak menyimpan `BuildContext`.
- Screen dan widget tidak mengimpor `services/` maupun `repositories/`.