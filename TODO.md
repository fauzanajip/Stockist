# TODO List - Stockist App

## High Priority - Screen Implementation

| #   | Task                                                          | Status     | File                               |
| --- | ------------------------------------------------------------- | ---------- | ---------------------------------- |
| 1   | Implement Create Event Screen - call bloc                     | ✅ DONE    | `create_event_screen.dart`         |
| 2   | Implement Event Setup Screen - assign produk & SPG            | ✅ DONE    | `event_setup_screen.dart`          |
| 3   | Implement SPG List Screen with dashboard view (PRD 7.1)       | ✅ DONE    | `spg_list_screen.dart`             |
| 4   | Implement Initial Distribution Screen - input qty per product | ✅ DONE    | `initial_distribution_screen.dart` |
| 5   | Implement Topup Screen - add stock to SPG                     | ✅ DONE    | `topup_screen.dart`                |
| 6   | Implement Return Screen - return stock from SPG               | ✅ DONE    | `return_screen.dart`               |
| 7   | Implement Sales Input Screen - update qty_sold per product    | ✅ DONE    | `sales_input_screen.dart`          |
| 8   | Implement Cash Input Screen - cash_received + qris_received   | ✅ DONE    | `cash_input_screen.dart`           |
| 9   | Implement Closing Screen with summary table & validation      | ✅ DONE    | `spg_closing_screen.dart`          |
| 10  | Global Event Stock Tracking (Stock from Distributor)          | ✅ DONE    | `event_setup_screen.dart`          |

## Medium Priority - Features

| #   | Task                                                          | Status  | Notes                                       |
| --- | ------------------------------------------------------------- | ------- | ------------------------------------------- |
| 11  | Add business logic calculations (total_dikasih, surplus, etc) | ✅ DONE | `stock_calculator.dart` - PRD Section 5     |
| 12  | Implement Export Excel functionality                          | ✅ DONE | Fully integrated in `HomeScreen` Dashboard   |
| 13  | Implement Backup JSON (Export database)                       | ✅ DONE | `backup_service.dart` - PRD Section 6.10     |
| 14  | Implement Restore JSON (Import backup)                        | ✅ DONE | `backup_service.dart` - PRD Section 6.10     |
| 15  | Settings Screen - Master Data Management                      | ✅ DONE | Add Product, SPG, SPB with BLoC integration |

## Low Priority - Bloc Fixes

| #   | Task                                                     | Status     | Location                |
| --- | -------------------------------------------------------- | ---------- | ----------------------- |
| 16  | Fix StockBloc error states                               | ✅ DONE    | Lines 39, 60, 81, 94    |
| 17  | Fix SPGBloc implementation                               | ✅ DONE    | Lines 16, 24            |
| 18  | Consolidate `EventDetailScreen` into `HomeScreen`         | ✅ DONE    | Dashboard-First Architecture            |
| 19  | Fix SalesBloc error states                               | ⏳ Pending | Lines 33, 49            |
| 20  | Fix CashBloc error states                                | ⏳ Pending | Lines 34, 52            |
| 21  | Fix ProductBloc implementation                           | ✅ DONE    | Lines 16, 24            |
| 22  | Add status indicators (READY/REVIEW) based on data match    | ✅ DONE    | SpgList & SpgDetail     |
| 23  | Fix DatePicker error in Event Setup                      | ✅ DONE    | Localization fix        |
| 24  | Add 'Reset Semua Data' (Clean Wipe) with warning dialog   | ✅ DONE    | Danger Zone in Settings |

## Low Priority - Stock Distribution Audit

| #   | Task                                                          | Status     | Notes                                       |
| --- | ------------------------------------------------------------- | ---------- | ------------------------------------------- |
| 25  | Create Stock History Screen (reusable from Home & SPG Detail) | ⏳ Pending | Entry points: MANAGEMENT section & SETUP section |
| 26  | Add UpdateStockMutation event & handler with validation       | ⏳ Pending | Validate: newQty >= (totalSold + totalReturn - otherDistributions) |
| 27  | Add DeleteStockMutation event & handler with validation       | ⏳ Pending | Validate: (otherDistributions - totalReturn) >= totalSold |
| 28  | Add update() method to StockMutationRepository                | ⏳ Pending | Implement in repository impl                |

---

## Progress Summary

- ✅ Completed: 20/28 (71%)
- ⏳ Pending: 8/28 (29%)

## PRD Reference

- PRD Section 6.1: Create Event flow ✅
- PRD Section 6.2: Setup Data (Event Setup) ✅
- PRD Section 6.3-6.8: Stock & Sales operations ✅ (All screens implemented with BLoC integration)
- PRD Section 6.9: Edit & Delete Distribusi ⏳ (Tasks #25-28 pending)
- PRD Section 6.10: Backup ✅ (Service created, needs UI wiring)
- PRD Section 7.1: Home Screen (Active Event Dashboard) ✅ (Consolidated & Auto-detect)
- PRD Section 8: Export Excel ✅ (Directly in main Dashboard)
- **Danger Zone**: Reset All Data feature implemented (with 2-step confirmation) ✅

## Completed Features (Last Update)

1. StockCalculator - all business logic calculations
2. ExcelExportService - multi-sheet export with summary + detail sheets
3. BackupService - export/import JSON via Android Share Sheet
4. All placeholder screens created with Industrial Brutalism dark mode design
5. **Create Event Screen** - Full BLoC integration:
   - Form validation (nama event min 3 karakter)
   - Date picker for event date
   - Loading state during creation
   - Navigate to Home after success
   - Error handling with SnackBar
6. **Event Setup Screen** - Full implementation with tab navigation:
   - Tab Produk: Assign/unassign products with custom price per event
   - Tab SPG: Assign/unassign SPGs with optional SPB assignment
   - Real-time switch toggles with BLoC state management
   - Price input field for assigned products (editable)
   - SPB dropdown for SPG assignment
   - Save setup button that navigates to home dashboard
7. **Home Screen (Dashboard-First)**:
   - Integrated `EventDashboardView` directly for active events.
   - Auto-detection of active event from BLoC state.
   - Clean empty state with Quick Actions (Pilih Event / Buat Event).
   - Integrated **Excel Export** langsung dari Dashboard utama.
8. **Architecture Consolidation**:
   - **Removed `EventDetailScreen`**: Menyatukan logika dashboard ke dalam `HomeScreen`.
   - **Navigational Alignment**: Alur simpan setup sekarang langsung mendarat di Dashboard Home.
   - **AppBar Synchronization**: AppBar Dashboard kini konsisten dengan icon Export dan Settings.
9. **SPG List Screen** - Dashboard view per SPG with:
   - Total dikasih, terjual, sisa calculations
   - Cash received display
   - Status indicator (✅/⚠️) based on surplus/selisih
   - Navigate to SPG detail on tap
10. **Settings Screen** - Master Data Management with 3 tabs:
    - Tab Produk: Add product (name, SKU, default price), list all products, soft delete
    - Tab SPG: Add SPG (name), list all SPGs, soft delete
    - Tab SPB: Add SPB (name), list all SPBs, delete
11. **Bloc Providers** - Added all blocs to MultiBlocProvider in main.dart
12. **SpbBloc** - New bloc for SPB management (LoadAll, Create, Delete)
13. **UpdateEventProductPrice Use Case** - Added for dynamic price updates
14. **Router** - Added /settings route for master data management
15. **SPG Dashboard Optimization**:
    - Implemented **Batch Loading Architecture**: Loads all event data (Stock, Sales, Cash) in one go.
    - Added **Per-Product Detailed Tracking**: Collapsible breakdown showing Distributed, Sold, and Remaining.
    - **Premium UI Overhaul**: Upgraded `SpgListScreen` and `SpgDetailScreen` to a modern dashboard aesthetic.
16. **Event Setup Overhaul (Search, Draft & Integrity)**:
    - **Draft & Save**: Implemented in-memory drafting for Event Setup.
    - **Searchable UI**: Added search capability (Names & SKU) and "Show Active Only" filters.
    - **History Guard**: Prevented unassigning Products/SPGs if transactions exist.
17. **Home Screen Optimization**:
    - **Reactivity Fix**: Converted to StatefulWidget with automatic `LoadAllEvents` on init.
    - **Pull-to-Refresh**: Added RefreshIndicator for manual data syncing.
18. **Reset All Data (Danger Zone)**:
    - Fitur penghapusan seluruh database (Master & Transaksi).
    - Dialog peringatan konfirmasi 2 langkah untuk keamanan data.
    - Terintegrasi di halaman Pengaturan bawah kategori "DANGER ZONE".
19. **Localization Fix**: Added `MaterialLocalizations` and `GlobalWidgetsLocalizations` to support DatePicker on all devices.
20. **Topup Screen** - Full BLoC integration:
    - Product selection from assigned products in event.
    - Quantity input with increment/decrement buttons.
    - Optional note field for additional information.
    - Submit via `CreateTopup` event to StockBloc.
    - Success feedback and auto-pop navigation.
21. **Return Screen** - Full BLoC integration with validation:
    - Product selection showing available qty to return (based on stock in hand).
    - Warning header with caution message (PRD 6.7: different color styling).
    - Max return validation - cannot exceed (total_given - total_returned).
    - Quantity input with increment/decrement buttons (max limit enforced).
    - Optional note field for retur reason.
    - Submit via `CreateReturn` event to StockBloc.
    - Products with no stock available shown as "N/A" (disabled for selection).
22. **Sales Input Screen** - Full BLoC integration:
    - List all assigned products with current stock info.
    - Show previous qty_sold (if exists) for reference.
    - Quantity input with max validation (cannot exceed stock in hand).
    - Batch submit via `UpdateSales` events to SalesBloc.
    - Replace value behavior (PRD 6.5: previous_qty tracked in DB).
23. **Cash Input Screen** - Full BLoC integration:
    - Input for Cash Tunai (cash_received).
    - Input for QRIS (qris_received, boleh 0).
    - Expected Cash calculation displayed based on sales × price.
    - Total Actual Cash summary (cash + qris).
    - Optional note field.
    - Submit via `UpdateCashRecord` event to CashBloc.
24. **Closing Screen** - Full BLoC integration with PRD 6.8 requirements:
    - Summary table per product: Dikasih, Return, Terjual, Sisa System, Sisa Real (input), Selisih.
    - Selisih Fisik calculation: sisa_system - sisa_real.
    - Cash summary: Expected Cash, Cash Tunai, QRIS, Total Actual, Surplus/Selisih.
    - Status indicator: ✅ if no selisih & surplus = 0, ⚠️ otherwise.
    - Validation before closing: all products have sales data & cash is input.
    - Visual highlighting for products with selisih (warning color).
    - Closing button disabled until validation passes.

## Upcoming Features (Planned)

25. **Stock History Screen** - Riwayat Distribusi (Audit):
    - Reusable screen accessible from Home Dashboard (MANAGEMENT) & SPG Detail (SETUP).
    - Parameter `spgId` optional: null = show all mutations, non-null = filter specific SPG.
    - Filter chips: [All] [Initial] [Topup] [Return].
    - Card list showing: Product, Type, Qty, Timestamp, SPG.
    - Tap card for edit dialog with qty counter.
    - Swipe-to-delete or long-press menu for delete action.
    - Validation before edit/delete to prevent negative stock.

26. **Edit Stock Mutation** - Validation Logic:
    - Use case: `UpdateStockMutation` with params (mutationId, newQty).
    - Validation formula: `newQty >= (totalSold + totalReturn - otherDistributions)`.
    - Error message: "Qty tidak bisa lebih kecil dari yang sudah terjual".
    - Bloc event: `UpdateStockMutation` added to StockBloc.

27. **Delete Stock Mutation** - Validation Logic:
    - Use case: `DeleteStockMutation` with params (mutationId).
    - Validation formula: `(otherDistributions - totalReturn) >= totalSold`.
    - Error message: "Tidak bisa hapus, stok sudah ada yang terjual".
    - Confirmation dialog before delete (destructive action).
    - Bloc event: `DeleteStockMutation` added to StockBloc.

28. **Stock Mutation Repository Update**:
    - Add `update()` method to `StockMutationRepository` interface.
    - Implement `update()` in `StockMutationRepositoryImpl`.
    - Update mutation record in SQLite: `UPDATE stock_mutations SET qty = ? WHERE id = ?`.
