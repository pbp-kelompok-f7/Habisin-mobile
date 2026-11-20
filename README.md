<div align="center">
<h1>🥄 Habisin 🥄</h1>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)

</div>

Habisin adalah platform yang dirancang untuk membantu masyarakat mengurangi limbah makanan rumah tangga.
Pengguna cukup memasukkan data sisa bahan makanan di kulkas mereka, lalu sistem akan merekomendasikan resep masakan
yang relevan. Website ini memberikan manfaat bagi pengguna untuk menghemat pengeluaran sekaligus mengurangi limbah
makanan yang mereka hasilkan.

Platform ini mengintegrasikan TheMealDB API untuk pencarian bahan dan resep. Pengguna tidak hanya bisa menemukan ide
masakan, tetapi juga dapat mengelola _fridge inventory_ mereka, menyimpan resep, melacak porsi makanan yang
terselamatkan, hingga saling berbagi _review_ antarpengguna.

## Anggota Kelompok

1. Aditya Hamka Pratama (2506552752)
2. Ahsan Rifqi Prasetyo (2506624266)
3. Amelinda Fedora Faragusti (2506540475)
4. Risyad Athaya Muhammad (2506595890)
5. Umar Faiz Rahman (2506616711)

## Daftar Modul

- Authentication, Profile, & Fridge Inventory (Aditya Hamka Pratama)

Bertanggung jawab atas keamanan akses pengguna (registrasi dan login) serta pengelolaan identitas (profile) dan
preferensi personal mereka. Selain itu, juga mengelola ketersediaan bahan makanan sisa yang dimiliki pengguna di rumah
untuk nantinya digunakan sebagai input pencarian.

- Community / Personal Reviews (Amelinda Fedora Faragusti)

Section yang memfasilitasi pengguna untuk menilai resep masakan yang sudah mereka coba buat.

- Recipe Discovery & Bookmarks (Risyad Athaya Muhammad)

Melakukan pencarian berdasarkan bahan yang diinput oleh pengguna (atau ada di fridge inventory). Selain itu, juga
dapat menambahkan resep ke beberapa list kategori (_bookmarks_), seperti _favourites_ dan _want to cook_.

- Saved Meals Tracker & History (Ahsan Rifqi Prasetyo)

Melihat porsi makanan yang terselamatkan serta masakan yang sudah berhasil dieksekusi sebelumnya. Daftar riwayat bisa
diubah dan dihapus oleh pengguna.

- Landing Page & Meals Planner (Umar Faiz Rahman)

Menyajikan halaman beranda untuk menyambut pengguna baru dan halaman lain yang membantu pengguna merencanakan makanan
sehari-hari berdasarkan resep yang sudah disimpan.

## Jenis Pengguna

**TBD.**

## Link Figma

Figma: **Coming soon.**

## Daftar Endpoint Django REST Framework — Saved Meals & History (Ahsan Rifqi Prasetyo)

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/saved-meals/api/overview/` | Mengambil daftar `saved_meals`, `history_meals`, dan `metrics` (mendukung filter `?q=`, `?time_filter=`, `?calorie_filter=`). |
| `GET` | `/saved-meals/api/metrics/` | Mengambil 5 metrik dampak pengurangan limbah makanan & nutrisi dari seluruh `HISTORY` milik pengguna. |
| `GET`, `POST` | `/saved-meals/api/meals/` | `GET`: daftar meal (`?status=SAVED\|HISTORY`, filter). `POST`: menambah `SAVED` meal manual dengan estimasi nutrisi otomatis via OpenFoodFacts. |
| `GET`, `PATCH`, `DELETE` | `/saved-meals/api/meals/<meal_id>/` | Mengambil detail, memperbarui sebagian (auto-scale nutrisi saat porsi berubah), atau menghapus item meal milik pengguna. |
| `POST` | `/saved-meals/api/meals/from-recipe/<recipe_id>/` | Menambahkan resep dari TheMealDB ke `SAVED` secara idempotent. |
| `POST` | `/saved-meals/api/meals/<meal_id>/complete/` | Memindahkan item `SAVED` ke `HISTORY` (atau mengakumulasi porsi & nutrisi jika resep identik sudah ada di `HISTORY`). |
| `GET` | `/saved-meals/api/history/` | Mengambil daftar masakan berstatus `HISTORY` (mendukung filter) beserta `metrics`. |
| `PATCH`, `DELETE` | `/saved-meals/api/history/<meal_id>/` | Mengedit porsi (auto-scale nutrisi) dan catatan pribadi, atau menghapus entri dari `HISTORY`. |

## ⚙️ How to Run

```powershell
flutter pub get
flutter run
```

Untuk verifikasi analisis statis dan pengujian unit/widget:

```powershell
flutter analyze
flutter test
```
