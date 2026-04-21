# 📦 Stockist App

**Stockist** adalah aplikasi *mobile offline-first* yang dirancang khusus untuk mempermudah proses pengelolaan stok dan rekonsiliasi SPG (Sales Promotion Girl) pada event penjualan. Aplikasi ini bertujuan untuk menggantikan proses pencatatan manual berbasis Excel di lapangan yang rentan terhadap kesalahan, lambat, dan sulit untuk dilacak riwayatnya.

## 🎯 Tujuan Aplikasi
- Mencatat distribusi stok ke SPG secara cepat.
- Mengelola mutasi stok (Stok Awal, Tambahan/Topup, Retur).
- Memasukkan data penjualan manual dari sistem online.
- Menghitung sisa stok secara otomatis.
- Memvalidasi penerimaan kas (Tunai & QRIS) dibandingkan dengan estimasi penjualan.
- Menghasilkan laporan (Export to Excel) secara instan.

## ✨ Fitur Utama (Berdasarkan PRD)
- **Offline-First:** Sepenuhnya dapat beroperasi tanpa koneksi internet menggunakan database lokal SQLite.
- **Multi-Event Support:** Mengelola banyak event penjualan secara terpisah dengan status (Open/Closed).
- **Master Data Management:** Pengelolaan data global untuk Produk (Rokok) dan SPG dengan dukungan *soft delete*.
- **Stock Distribution Tracking:** Melacak mutasi stok secara detail (Initial, Topup, Return).
- **Cash Reconciliation:** Menghitung otomatis surplus/selisih antara *Expected Cash* dengan uang yang diterima (Cash Tunai + QRIS).
- **Excel Export:** Ekspor laporan ringkasan event dan detail mutasi per SPG ke dalam format `.xlsx`.
- **Local Backup & Restore:** Pencadangan data event secara lokal ke format JSON dan fitur berbagi (*Share Sheet*).

## 🛠️ Teknologi & Stack (Tech Stack)
Aplikasi ini dibangun menggunakan framework **Flutter** dengan pendekatan **Clean Architecture**.

- **Framework:** Flutter (Dart) - SDK `^3.11.0`
- **State Management:** BLoC (`flutter_bloc`, `bloc_concurrency`)
- **Database Lokal:** SQLite (`sqflite`, `path`)
- **Dependency Injection:** `get_it`
- **Routing:** `go_router`
- **Utilitas:**
  - `dartz` (Functional programming/Error handling)
  - `equatable` (Value equality)
  - `excel` (Generate file Excel)
  - `share_plus` (Share file laporan/backup)
  - `intl` (Formatting angka dan tanggal)
  - `uuid` (Generate unique ID)

## 🏗️ Arsitektur Proyek
Aplikasi ini mengadopsi **Clean Architecture** untuk memastikan kode mudah di-maintain, diuji (testable), dan memiliki pemisahan tanggung jawab (Separation of Concerns) yang jelas.

```text
lib/
├── core/           # Konfigurasi aplikasi, error handling, utilitas, formatter, tema
├── data/           # Implementasi repository, data sources (SQLite), dan models
├── domain/         # Business logic: Entities, Usecases, dan antarmuka Repositories
├── presentation/   # UI layer: Screens, BLoC (State Management), dan Routers
├── dependency_injection.dart # Setup get_it locator
└── main.dart       # Entry point aplikasi
```

## 🚀 Cara Menjalankan Aplikasi

1. **Pastikan Flutter SDK sudah terinstal** di sistem Anda (versi 3.11.0 atau lebih baru).
2. **Clone repositori ini** ke komputer Anda.
3. **Install dependensi:**
   ```bash
   flutter pub get
   ```
4. **Jalankan aplikasi di perangkat atau emulator:**
   ```bash
   flutter run
   ```
   *Catatan: Karena aplikasi ini menggunakan SQLite (`sqflite`), disarankan untuk menjalankannya di perangkat fisik Android/iOS atau emulator, bukan di Web.*

## 📈 Success Metrics
- Waktu input kurang dari 3 detik per transaksi.
- Berkurangnya tingkat error pencatatan manual secara signifikan.
- Proses *closing* SPG yang lebih cepat dibandingkan proses Excel manual.
- Data yang dihasilkan konsisten dan siap dicocokkan dengan sistem online.

---
*Dibuat berdasarkan PRD Stock SPG App v2.1 (April 2026)*
