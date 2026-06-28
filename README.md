# UAS Praktikum Pemrograman Mobile - Mobile Mart

Aplikasi E-commerce berbasis Flutter dengan implementasi State Management Provider, REST API Integrasi, dan Arsitektur Clean Code.

---

## 👤 Identitas Mahasiswa
*   **Nama**       : Muhamad Ar Rasyid Rizki Oktavian
*   **NIM**        : 2306045
*   **Kelas**      : B
*   **Mata Kuliah**: Praktikum Pemrograman Mobile (Semester 6)

---

## 📱 Deskripsi Aplikasi: Mobile Mart
**Mobile Mart** adalah aplikasi *e-commerce* modern yang dirancang khusus untuk memfasilitasi transaksi belanja online yang ringkas, cepat, dan aman. Aplikasi ini mengusung tema desain *Light Minimal Modern* dengan nuansa warna biru elektrik yang bersih dan interaksi transisi yang mulus.

Aplikasi ini memiliki sistem otorisasi tingkat peran (Role-Based Authorization) yang memisahkan alur kerja pengguna menjadi dua bagian utama:
1.  **Customer Flow**: Memungkinkan pembeli mencari produk, memfilter kategori, membaca/menulis ulasan produk, mengelola keranjang belanja, hingga melakukan proses checkout pesanan.
2.  **Admin Flow (Opsi A - Admin Dashboard)**: Menyajikan panel ringkasan performa bisnis toko (total pendapatan, total pelanggan, jumlah pesanan) dalam bentuk visual kartu statistik dan grafik batang interaktif penjualan produk terlaris menggunakan `fl_chart`, serta memfasilitasi manajemen pengelolaan status pesanan pelanggan.

---

## 🎨 Screenshot Aplikasi
*(Catatan: Silakan letakkan gambar screenshot berukuran proporsional pada folder `docs/screenshots/`)*

| Halaman Splash & Login | Katalog & Detail Produk | Keranjang Belanja & Checkout |
| :---: | :---: | :---: |
| ![Login](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Halaman Login* | ![Catalog](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Beranda Produk & Filter* | ![Cart](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Keranjang & Checkout* |

| Dashboard & Statistik Admin | Peringkat Produk Terlaris | Manajemen Pesanan Pelanggan |
| :---: | :---: | :---: |
| ![Dashboard](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Dashboard Statistik* | ![Top Products](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Grafik Produk Terlaris* | ![Manage Orders](https://raw.githubusercontent.com/flutter/documents/main/images/logo.png) <br> *Kelola Status Pesanan* |

---

## 🚀 Fitur yang Diimplementasikan

### A. Fitur Utama Pelanggan (Customer)
*   **Autentikasi Aman**: Register pelanggan baru, Login dengan token Bearer, Auto-login persistent menggunakan `shared_preferences`, dan Logout hapus sesi.
*   **Katalog Belanja**: List produk dinamis, Search bar dengan debounce 500ms, Filter horizontal kategori (Choice Chips), dan Sorting Dropdown (Terbaru, Harga Terendah, Harga Tertinggi).
*   **Pagination / Infinite Scroll**: Memuat data halaman katalog secara bertahap saat pengguna men-scroll mendekati bawah grid belanja.
*   **Detail Produk Lengkap**: Gambar, stok interaktif, deskripsi produk, ulasan pembeli (format tanggal ID), serta form rating bintang dan komentar ulasan real-time.
*   **Keranjang Belanja (Cart)**: Tambah item, ubah kuantitas `+`/`-` dinamis, hapus item, kosongkan keranjang belanja dengan dialog konfirmasi, dan Badge Counter pada tab navigasi.
*   **Checkout & Pesanan**: Form pengisian alamat (min 10 karakter) & nomor telepon terintegrasi validator, popup konfirmasi pesanan, riwayat pesanan (UUID 8 karakter pertama), dan detail pesanan lengkap.

### B. Fitur Tambahan (Opsi A - Admin Dashboard)
*   **Statistik Dashboard**: Ringkasan performa toko (Total Pendapatan Rupiah, Total Pesanan, Produk Aktif, Total Pelanggan, dan Pesanan Pending).
*   **Visual Chart (fl_chart)**: Grafik batang interaktif menampilkan volume penjualan produk terlaris di bagian atas layar Top Products.
*   **Manajemen Pesanan**: List pesanan seluruh pelanggan dengan filter Choice Chips status aktif.
*   **Perbaruan Status Pesanan**: Dropdown perubahan status pesanan dengan validasi (Status `Delivered` dan `Cancelled` tidak dapat diubah kembali).

---

## 🔑 Kredensial Pengujian
Untuk masuk sebagai Administrator Toko:
*   **Email**: `admin@admin.com`
*   **Password**: `admin123`

---

## 🌐 Informasi API
Aplikasi terhubung ke backend server melalui endpoint berikut:
*   **Base URL**: `https://api-tb-f2wk.onrender.com/api`
*   **Endpoints Utama**:
    *   Auth: `POST /auth/register`, `POST /auth/login`, `GET /auth/profile`, `PUT /auth/profile`
    *   Product: `GET /products`, `GET /products/:id`
    *   Categories: `GET /categories`
    *   Reviews: `GET /reviews/product/:productId`, `POST /reviews/product/:productId`
    *   Cart: `GET /cart`, `POST /cart`, `PUT /cart/:id`, `DELETE /cart/:id`, `DELETE /cart`
    *   Orders: `GET /orders`, `POST /orders`, `GET /orders/:id`
    *   Admin: `GET /dashboard/stats`, `GET /dashboard/top-products`, `GET /orders/admin/all`, `PUT /orders/:id/status`

---

## 🛠️ Cara Menjalankan Aplikasi Secara Lokal

### Prasyarat
*   Sudah menginstal Flutter SDK (versi >= 3.0.0).
*   Perangkat emulator Android/iOS atau real device yang terhubung.

### Langkah-langkah
1.  Kloning repositori ini:
    ```bash
    git clone <url-repository>
    cd uas_prakpemrogramanmobile
    ```
2.  Ambil semua dependensi package:
    ```bash
    flutter pub get
    ```
3.  Jalankan aplikasi di perangkat target:
    ```bash
    flutter run
    ```

---

## 📦 Cara Build APK Release

Untuk melakukan kompilasi proyek menjadi berkas APK rilis siap instal di Android, jalankan perintah berikut di terminal root proyek:

```bash
flutter build apk --release
```

### 📍 Output Folder & Lokasi APK
Setelah kompilasi selesai, berkas APK rilis akan tersimpan di direktori berikut:
📁 **`build/app/outputs/flutter-apk/app-release.apk`**

---

## 🎥 Link Video Demo Aplikasi
Berikut adalah rekaman video demonstrasi seluruh fitur aplikasi Mobile Mart (Login/Register, Pembelian Customer, dan Dashboard Admin):
🔗 **[Link Video Demo Aplikasi (YouTube / Google Drive Placeholder)](#)**
