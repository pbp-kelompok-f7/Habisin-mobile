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

Untuk checkpoint Meals Planner, pengguna dapat melihat katalog resep publik dan menyusun menu tanpa login. Menu disimpan di memori selama aplikasi terbuka.

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
## Menjalankan checkpoint Meals Planner

Jalankan dari folder Flutter:

```sh
flutter pub get
flutter run -d chrome
```

Di beranda, pilih **Buka Meals Planner**, pilih hari dan tambah resep untuk sarapan, makan siang, atau makan malam. Cari resep lewat nama atau bahan. Mengganti atau menghapus resep akan memperbarui progres dari 21 waktu makan dan daftar bahan minggu tersebut. Pindah minggu lalu kembali untuk melihat menu yang sudah dipilih. Menutup halaman planner tetap menyimpan rencana selama aplikasi terbuka. Memuat ulang aplikasi mengosongkannya.

### Endpoint checkpoint

| Metode | Path Django | Akses | Respons |
| --- | --- | --- | --- |
| GET | `/api/meals-planner/recipes/` | Publik | Objek `recipes` berisi daftar resep dengan `id`, `name`, `ingredients`, dan `image_url`. |
| GET | `/api/meals-planner/week/?week=YYYY-MM-DD` | Login | Rencana makan mingguan pengguna. Gunakan tanggal Senin atau hilangkan parameter `week` untuk minggu berjalan di zona waktu Jakarta. |
| PUT | `/api/meals-planner/menu/YYYY-MM-DD/{slot}/` | Login | Isi atau ganti resep pada slot tersebut dengan body JSON, misalnya `{"recipe":"mealdb:52772"}`. |
| DELETE | `/api/meals-planner/menu/YYYY-MM-DD/{slot}/` | Login | Hapus menu pada slot tersebut. Kirim permintaan tanpa body. |

Untuk ketiga endpoint pribadi, ambil token melalui `POST /api/auth/login/` lalu sertakan header `Authorization: Token <token>`. Nilai `slot` dapat berupa `breakfast`, `lunch`, atau `dinner`. Saat berhasil, ketiganya mengembalikan HTTP 200 dengan rencana mingguan, progres, dan daftar bahan terbaru. Flutter pada checkpoint ini membaca katalog dan menyimpan perubahan menu di memori aplikasi. URL katalog sebelumnya, `/meals-planner/api/recipes/`, tetap tersedia sebagai alias.

Endpoint DRF memakai katalog TheMealDB yang juga digunakan situs Habisin. Untuk demo dengan data API, jalankan [branch Django checkpoint](https://github.com/pbp-kelompok-f7/Habisin/tree/feature/meals-planner-checkpoint-api) di terminal terpisah. Setelah memasang requirements dan mengatur `.env` lokal sesuai README Django:

```sh
python manage.py migrate
python manage.py runserver 127.0.0.1:8010
```

Buka [katalog JSON lokal](http://127.0.0.1:8010/api/meals-planner/recipes/) untuk memeriksa respons. Hubungkan Flutter Web ke katalog dengan:

```sh
flutter run -d chrome --dart-define=PLANNER_API_URL=http://127.0.0.1:8010/api/meals-planner/recipes/
```

Untuk emulator Android, pilih device emulator dan ganti host di URL dengan `10.0.2.2`. Tanpa URL API, aplikasi memakai tiga resep contoh dengan foto lokal. Jika API tak dapat dihubungi, pengguna tetap dapat memakai resep contoh atau mencoba memuat katalog lagi.
