# 📄 PRODUCT REQUIREMENTS DOCUMENT (PRD)

## Mobile Offline Stock & SPG Reconciliation App

**Versi:** 2.7 — Complete Stock Audit & Edit  
**Tanggal:** April 2026

---

## 1. 📌 Overview

### 1.1 Background

Dalam event penjualan rokok, stokist bertanggung jawab untuk:

- **Menerima stok dari distributor (Global Event Stock)**
- Mendistribusikan stok ke SPG (Sales Stock)
- Mencatat pergerakan stok (awal & tambahan)
- Memvalidasi jumlah penjualan
- Melakukan rekonsiliasi uang cash saat closing

Saat ini proses dilakukan menggunakan Excel manual yang:

- Rentan error
- Lambat di lapangan
- Tidak real-time
- Sulit tracking history

---

### 1.2 Objective

Membangun aplikasi mobile offline untuk:

- Mencatat distribusi stok ke SPG
- Mengelola mutasi stok (awal, tambah, retur)
- Input data penjualan manual dari sistem online
- Menghitung sisa stok otomatis
- Validasi cash vs penjualan
- Generate laporan Excel

---

### 1.3 Target User (Persona)

**Stockist Event**

- Mengelola banyak SPG dalam satu event
- Bekerja di kondisi lapangan (cepat, mobile, offline)
- Fokus pada akurasi dan kecepatan input

---

## 2. 🎯 Scope

### 2.1 In Scope

- Offline-first mobile app
- Multi-event support
- SPG management
- Product (rokok) management
- Stock distribution tracking
- Sales manual input
- Cash reconciliation (tunai + QRIS)
- Excel export

---

### 2.2 Out of Scope (Phase 1)

- API integration ke sistem online
- Real-time sync
- Multi-device sync
- Role management (admin, dll)

---

## 3. 🧠 Core Concept

### 3.1 Data Flow

```
Distributor → Event (Global Stock) → SPG (Sales Stock) → Customer
```

App mencatat:

1. **Terima dari Distributor**: Distributor → Event
2. **Distribusi Sales**: Event → SPG
3. **Mutasi Samping**: Gudang Event ↔ SPG

---

### 3.2 Source of Truth

- Penjualan: Sistem online (input manual ke app)
- Stock: App (berdasarkan distribusi & mutasi)

---

## 4. 🧱 Data Model

---

### 4.1 Event

```
id
name
date
status (open | closed)
```

> ✅ Tambahan: `status` agar event yang sudah closed tidak bisa diedit sembarangan.

---

### 4.2 Product (Rokok) — Master Data Global

```
id
name
sku
price        ← harga default (referensi)
deleted_at (nullable)
```

> ✅ `deleted_at` untuk soft delete — produk yang dihapus tidak merusak histori transaksi.  
> ⚠️ `price` di sini hanya default. Harga aktual per event diambil dari `event_product.price`.

---

### 4.3 SPG — Master Data Global

```
id
name
deleted_at (nullable)
```

> ✅ `deleted_at` untuk soft delete — SPG yang dinonaktifkan tetap tercatat di histori.  
> ℹ️ `spb_id` dipindah ke `event_spg` karena assignment SPB bisa berbeda tiap event.

---

### 4.4 Event–SPG Mapping

```
id
event_id
spg_id
spb_id (nullable)   ← assignment SPB bisa beda tiap event
```

> ✅ Menentukan SPG mana saja yang aktif di suatu event.  
> Saat setup event, user memilih SPG dari master dan assign ke event ini.

---

### 4.5 Event–Product Mapping

```
id
event_id
product_id
price       ← harga produk khusus untuk event ini (override master)
```

> ✅ Menentukan produk mana saja yang dijual di suatu event, beserta harganya.  
> Formula `expected_cash` menggunakan `event_product.price`, bukan `product.price`.

---

### 4.6 SPB (Optional)

```
id
name
```

---

### 4.7 Stock Mutation (Core)

```
id
event_id
spg_id     ← jika distributor_to_event, gunakan ID khusus 'WAREHOUSE'
product_id
qty
type (distributor_to_event | initial | topup | return)
timestamp
note (nullable)
```

> ✅ Tambahan: `distributor_to_event` untuk mencatat stok yang masuk ke lokasi event sebelum dibagikan.  
> ✅ Tambahan: `note` opsional untuk keterangan khusus (misal: "retur karena basi").  
> ✅ Mutation records dapat di-edit atau di-delete dengan validasi.  
> ⚠️ Tidak boleh mengubah qty jika menyebabkan `sisa_system` negatif.

---

### 4.8 Sales Manual

```
id
event_id
spg_id
product_id
qty_sold
updated_at
previous_qty (nullable)
```

> ⚠️ Value selalu **replace (bukan incremental)**.  
> ✅ Tambahan: `previous_qty` untuk menyimpan nilai sebelumnya — membantu audit jika ada dispute perubahan angka.

---

### 4.9 Cash Record

```
id
event_id
spg_id
cash_received
qris_received
note (nullable)
```

> ✅ Perubahan kritis: Pisah `cash_received` dan `qris_received` karena keduanya dipakai di kalkulasi surplus dan export Excel.

---

### 4.10 Backup Log

```
id
event_id
file_name
timestamp
status (success | failed)
```

---

## 5. 🔄 Core Logic

---

### 5.1 Total Stok Diberikan ke SPG

```
total_dikasih = SUM(qty where type = 'initial' OR type = 'topup')
```

---

### 5.2 Total Return

```
total_return = SUM(qty where type = 'return')
```

---

### 5.3 Total Terjual

```
total_terjual = qty_sold (dari Sales Manual)
```

---

### 5.4 Sisa Sistem

```
sisa_system = (total_dikasih - total_return) - total_terjual
```

---

### 5.5 Expected Cash

```
expected_cash = total_terjual × event_product.price
```

> ⚠️ Gunakan harga dari `event_product.price` (bukan `product.price`) karena harga bisa berbeda tiap event.

---

### 5.6 Actual Cash

```
actual_cash = cash_received + qris_received
```

---

### 5.7 Surplus / Selisih Cash

```
surplus = actual_cash - expected_cash
```

> Positif (+) = kelebihan uang  
> Negatif (-) = kekurangan uang

---

## 6. 📱 User Flow

---

### 6.1 Create Event

- Input nama event
- Input tanggal
- Status otomatis: `open`

---

### 6.2 Setup Data (Per Event)

**Assign Produk ke Event:**

- Pilih produk dari master (bisa pilih semua atau sebagian)
- Set harga produk untuk event ini (default dari `product.price`, bisa di-override)
- **Input Stok Awal distributor**: Menetapkan jumlah stok masuk ke gudang event.
- **Drafting Mechanism**: Seluruh perubahan tersimpan di memori sementara. Data baru masuk ke DB utama saat tombol **"SIMPAN SETUP"** ditekan.
- **Data Integrity**: Mencegah unassign jika sudah ada history transaksi.
- Produk yang dipilih tersimpan di `event_product`

**Assign SPG ke Event:**

- Pilih SPG dari master (bisa pilih semua atau sebagian)
- (Opsional) Assign SPB untuk masing-masing SPG di event ini
- SPG yang dipilih tersimpan di `event_spg`

> ✅ SPG dan produk yang tidak di-assign tidak akan muncul di event ini.  
> ✅ Master data SPG dan produk bisa dipakai ulang di event berikutnya.

---

### 6.3 Distribusi Awal (AWAL)

- Pilih SPG
- Input jumlah tiap produk
- Simpan sebagai `mutation type = initial`

---

### 6.4 Tambah Stok (TAMBAH)

- Pilih SPG
- Pilih produk
- Input qty
- Simpan sebagai `mutation type = topup`

---

### 6.5 Update Penjualan (TERJUAL)

- Pilih SPG
- Input qty per produk
- **Replace value sebelumnya** (nilai lama disimpan di `previous_qty`)

---

### 6.6 Input Cash

- Pilih SPG
- Input uang **cash tunai** diterima
- Input uang **QRIS** diterima (boleh 0)

---

### 6.7 Return Stok (RETUR)

- Pilih SPG
- Pilih produk
- Input qty
- Simpan sebagai `mutation type = return`

> ⚠️ UI: Tombol Retur harus **beda warna** (merah/kuning) agar tidak tertukar dengan Tambah Stok.

---

### 6.8 Closing Event (Per SPG)

Sistem menampilkan ringkasan otomatis:

| Item                       | Nilai           |
| -------------------------- | --------------- |
| Total Dikasih              | `total_dikasih` |
| Total Return               | `total_return`  |
| Total Terjual              | `total_terjual` |
| Sisa Sistem                | `sisa_system`   |
| Expected Cash              | `expected_cash` |
| Actual Cash (Tunai + QRIS) | `actual_cash`   |
| Surplus/Selisih            | `surplus`       |

User input tambahan:

- **Sisa Real** (hasil hitung fisik stok)
- App menampilkan: `selisih_fisik = sisa_system - sisa_real`

**Kriteria Status:**

- ✅ = `selisih_fisik = 0` DAN `surplus = 0`
- ⚠️ = ada selisih stok ATAU selisih cash

**Closing dapat dilakukan hanya jika:**

- Semua produk sudah ada data `qty_sold` (minimal nilai 0)
- `cash_received` sudah diinput

**Re-open Closing:**

- Closing per SPG **bisa di-reopen** oleh user selama event masih `status = open`
- Event di-close permanen hanya saat user menekan "Tutup Event"

---

### 6.9 Edit & Delete Distribusi (AUDIT)

**Riwayat Distribusi Screen:**

- Menampilkan semua mutation records (initial, topup, return)
- Filter by type, product, SPG
- Entry points:
  - Home Dashboard → MANAGEMENT section → "Riwayat Distribusi" (view all SPG)
  - SPG Detail → SETUP section → "Riwayat Distribusi" (view specific SPG)
- Reusable screen dengan parameter `spgId` (optional)

**Edit Mutation:**

- Ubah qty distribusi yang sudah ada
- Validation: `newQty >= (totalSold + totalReturn - otherDistributions)`
- Jika invalid: tampilkan error "Qty tidak bisa lebih kecil dari yang sudah terjual"
- Tap card untuk edit → dialog dengan qty counter

**Delete Mutation:**

- Hapus record distribusi
- Validation: `(otherDistributions - totalReturn) >= totalSold`
- Jika invalid: tampilkan error "Tidak bisa hapus, stok sudah ada yang terjual"
- Konfirmasi dialog sebelum delete (destructive action)
- Swipe-to-delete atau long-press menu

---

### 6.10 Local Backup (Keamanan Data)

- User masuk ke Menu Settings/Backup
- Klik tombol **"Ekspor Data Event"**
- Sistem mengonversi database SQLite menjadi file `.json`
- Sistem memicu Android Share Sheet (WhatsApp, Google Drive, dll)

> ✅ Format backup dipilih: **JSON** (lebih portable, bisa dibaca manual jika perlu restore).  
> ⚠️ Reminder otomatis muncul setiap 4 jam atau setelah sesi distribusi besar.

---

## 7. 🖥️ UI / UX Requirements

---

### 7.1 Home Screen (Active Event Dashboard)

Halaman utama aplikasi yang berfungsi sebagai **pusat kendali (Command Center)** untuk event yang sedang aktif.

- **Auto-Detection**: Jika ada event yang diset aktif, sistem langsung menampilkan `EventDashboardView`.
- **Statistik Real-time**: Menampilkan ringkasan Dikasih, Terjual, Sisa, dan Cash per SPG secara langsung.
- **Export directly**: Tombol **Export Excel** tersedia langsung di AppBar untuk kemudahan pelaporan cepat.
- **Empty State**: Jika belum ada event aktif, menampilkan panduan (CTA) untuk memilih event fokus atau membuat event baru.

**Management Section:**

- 👥 **Daftar SPG** — absensi dan performa individu
- ⚙️ **Setup Event** — konfigurasi produk & petugas
- 📋 **Riwayat Distribusi** — audit semua mutation records (all SPG)

---

### 7.2 SPG Detail Screen

**Transactions Section:**

- ➕ **Tambah Stok** (hijau)
- 🔄 **Retur Stok** (merah/kuning)
- 📊 **Update Sales**
- 💰 **Input Cash**

**Setup Section:**

- 📋 **Distribusi Awal** — set stok awal untuk event ini
- 📋 **Riwayat Distribusi** — audit & edit/delete mutation records

**Closing:**

- 🔒 **Closing SPG**

---

### 7.3 Input UX Rules

- **Search & Filter (Scalability)**:
  - Halaman Setup dilengkapi dengan **Search Bar** (Nama/SKU) & toggle **"Filter Active Only"**.
- Min tap — numeric keypad langsung muncul
- Default ke pilihan terakhir (SPG / produk)
- Big touch area (lapangan-friendly)
- Konfirmasi dialog untuk aksi destruktif (retur, hapus)

---

### 7.4 Closing Screen

Menampilkan per produk:

| Produk   | Dikasih | Return | Terjual | Sisa Sistem | Sisa Real | Selisih |
| -------- | ------- | ------ | ------- | ----------- | --------- | ------- |
| Produk A | XX      | XX     | XX      | XX          | [input]   | XX      |

Summary:

- Expected Cash: Rp XX
- Actual Cash (Tunai): Rp XX
- Actual Cash (QRIS): Rp XX
- Total Actual: Rp XX
- Surplus/Selisih: ± Rp XX

---

## 8. 📊 Export Excel

---

### 8.1 Format Per Sheet

**Sheet: Ringkasan Event**

| SPG | Total Dikasih | Total Terjual | Total Return | Sisa Sistem | Cash Tunai | QRIS | Expected Cash | Surplus |
| --- | ------------- | ------------- | ------------ | ----------- | ---------- | ---- | ------------- | ------- |

- **Borders**: All cells have thin borders
- **Header Style**: Bold, centered, grey background
- **Alignment**: SPG column left-aligned, numbers center-aligned

**Sheet: Detail SPG**

| SPB | Name | PRODUCT A                      | PRODUCT B                      |
|     |      | AWAL | TAMBAH | RETURN | TERJUAL | SISA | AWAL | TAMBAH | RETURN | TERJUAL | SISA |
| --- | ---- | ---- | ------ | ------ | ------- | ---- | ---- | ------ | ------ | ------- | ---- |

- **SPB Column**: Shows SPB assignment for each SPG
- **Sorting**: SPGs grouped by SPB, sorted alphabetically (unassigned "-" last)
- **Cell Merge**: SPB cells merged vertically for consecutive SPGs with same SPB
- **TOTAL Row**: SPB + Name columns merged, shows "TOTAL" label
- **Borders**: All cells have thin borders
- **Header Style**: Bold, centered, grey background for headers

---

### 8.2 Format Angka

- Qty: Integer tanpa desimal
- Uang: Format `Rp #,##0` (contoh: `Rp 150.000`)

---

### 8.3 Output

- File `.xlsx`
- Per event
- Nama file: `[NamaEvent]_[Tanggal].xlsx`
- **Sheets**: Only "Ringkasan Event" and "Detail SPG" (Sheet1 removed)

---

### 8.4 Cash Input Enhancements (Session 2026-04-24)

- **Smart Validation**: 
  - New record: Button disabled if cash & qris both = 0
  - Existing record: Button enabled (allows setting values to 0 for future update)
- **Thousand Separator**: Numbers displayed with dots (e.g., 150.000) while typing
- **Leading Zero Prevention**: Formatter strips leading zeros automatically

---

### 8.5 SPG List Cash Display

- **Expected Cash**: Calculated from `qty_sold × product_price`
- **Cash Breakdown**: Shows Cash Tunai and QRIS separately
- **Total Actual**: Sum of cash + qris
- **Surplus/Deficit**: Color indicator when actual ≠ expected

---

### 8.6 Save + Open + Share Feature (Phase 2 - Session 2026-04-24)

**Export Flow**:
1. User clicks "Export Excel" button
2. Loading dialog shows: "Generating Excel..."
3. File generated in app documents
4. **Android**: Attempt save to Downloads/Stockist
5. **iOS**: Save to Documents/Stockist (visible in Files app)
6. Success dialog shows with options:
   - **Open File**: Launch with Excel viewer app
   - **Share**: Use Android/iOS share sheet
   - **Close**: Dismiss dialog

**Permission Handling (Android ≤9)**:
- If storage permission denied → PermissionDeniedDialog
- Options: Grant Permission / Share Only / Cancel
- Unlimited retry on Grant Permission
- Fallback to Share Only if permission still denied

**File Locations**:
| Platform | Save Location | User Access |
|----------|---------------|-------------|
| Android 10+ | Downloads/Stockist | File Manager → Downloads |
| Android ≤9 | Downloads/Stockist (needs permission) | File Manager → Downloads |
| iOS | Documents/Stockist | Files app → On My iPhone → Stockist |

**Packages Used**:
- `open_file_plus: ^3.0.0` - Open file with default app
- `permission_handler: ^11.0.1` - Android storage permissions

---

## 9. ⚙️ Technical Requirements

---

### 9.1 Platform

- Flutter (Android focus)
- **Minimum Android:** API 26 (Android 8.0 Oreo) ke atas

---

### 9.2 Database

- SQLite (offline-first)
- Migrasi skema menggunakan versi database (untuk update app di masa depan)

---

### 9.3 State Management

- Cubit / Bloc (lightweight)

---

### 9.4 Performance

- Fast load list SPG (target < 500ms)
- No lag saat input cepat (debounce 300ms jika perlu)

---

## 10. ⚠️ Edge Cases

---

### 10.1 Sales Tidak Diupdate

- Tampilkan: `Last updated: HH:mm` di kartu SPG
- Jika belum pernah diupdate: tampilkan `Belum ada data penjualan`

---

### 10.2 Selisih Stok

- Tampilkan warning jika `sisa_system ≠ sisa_real` saat closing

---

### 10.3 Over Cash / Under Cash

- Surplus positif: tampilkan `+ Rp XX (kelebihan)`
- Surplus negatif: tampilkan `- Rp XX (kekurangan)` dengan warna merah

---

### 10.4 Negative Case

- Input qty tidak boleh negatif
- Field wajib tidak boleh kosong
- Return qty tidak boleh melebihi total stok yang diberikan

---

### 10.5 Soft Delete

- SPG/Produk yang dihapus tidak muncul di daftar aktif
- Data histori tetap tersimpan dan tampil di laporan

---

### 10.6 Data Terhapus / HP Rusak

- **Mitigasi:** Reminder backup muncul setiap 4 jam
- **Auto-backup (Phase 1.1):** Backup otomatis setiap closing event per SPG

---

## 11. 🚀 Future Improvements

---

### Phase 1.1 (Security)

- Auto-Backup setiap kali user melakukan Closing Event per SPG

---

### Phase 2

- Sync ke backend
- Integrasi API sales
- Multi-device sync
- Role (Admin / SPB / SPG)

---

### Phase 3

- Analytics dashboard
- Auto reconciliation
- Real-time monitoring

---

## 12. ✅ Success Metrics

- Input time < 3 detik per transaksi
- Error manual berkurang signifikan
- Closing lebih cepat dari proses Excel manual
- Data konsisten dengan sistem online

---

## 📝 Changelog

| Versi | Perubahan                                                                                                                                                                                                                                                 |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v2.7  | Add **Edit & Delete Stock Distribution** feature with validation (PRD 6.9); Stock History Screen reusable from Home Dashboard & SPG Detail; Validation logic to prevent negative stock; Update TODO.md tasks #25-28.                                       |
| v2.6  | Implementasi lengkap **Sales Input**, **Cash Input**, dan **Closing Screen** dengan full BLoC integration; Validasi closing per PRD 6.8 (selisih fisik & surplus); Status indicator ✅/⚠️; Progress 83% completion.                                       |
| v2.5  | Implementasi **Topup Screen** & **Return Screen** dengan full BLoC integration; Validasi max return berdasarkan stock in hand; UI warning styling untuk retur (PRD 6.7); Progress menuju 96% completion.                                                  |
| v2.3  | Implementasi **Draft & Save Mechanism** pada Event Setup; Fitur **Search & Filter** untuk skalabilitas data besar; **Data Integrity Protection** (mencegah unassign jika ada history transaksi); **Optimasi Home Screen** dengan Pull-to-refresh.           |
| v2.2  | Tambah flow **Global Event Stock Tracking** (Distributor → Event); Update `StockMutationEntity` untuk mendukung tipe `distributor_to_event`; Update flow 6.2 Setup Data untuk input stok awal distributor.                                                |
| v2.1  | Opsi B fleksibel: tambah tabel `event_spg` dan `event_product`; SPG & Product jadi master data global; harga produk per-event di `event_product.price`; `spb_id` dipindah ke `event_spg`; update user flow 6.2 setup data; update formula `expected_cash` |
| v2.0  | Tambah `qris_received` di Cash Record; perbaiki formula surplus; definisikan kriteria status ✅/⚠️; perjelas closing flow (re-open, validasi); soft delete SPG & Product; detail export Excel; minimum Android version; pilih JSON sebagai format backup  |
| v1.0  | Initial PRD                                                                                                                                                                                                                                               |
