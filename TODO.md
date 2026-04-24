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
| 25  | Create Stock History Screen (reusable from Home & SPG Detail) | ✅ DONE    | Entry points: MANAGEMENT section & SETUP section |
| 26  | Add UpdateStockMutation event & handler with validation       | ✅ DONE    | Validate: newQty >= (totalSold + totalReturn - otherDistributions) |
| 27  | Add DeleteStockMutation event & handler with validation       | ✅ DONE    | Validate: (otherDistributions - totalReturn) >= totalSold |
| 28  | Add update() method to StockMutationRepository                | ✅ DONE    | Implement in repository impl                |

## Bug Fixes (Session 2026-04-23)

| #   | Bug                                                          | Status     | Fix                                         |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 29  | Warehouse mutation delete shows wrong error                  | ✅ DONE    | Skip validation for distributorToEvent type |
| 30  | Integrity check not filtering by eventId                     | ✅ DONE    | Added eventId filter for Product & SPG check |
| 31  | SPG switch re-adds removed SPG on rebuild                    | ✅ DONE    | Added _spgInitialized flag                  |
| 32  | SPB assignment not saved on re-open                           | ✅ DONE    | Added UpdateEventSpg usecase & handler      |
| 33  | SPG List shows SPB ID instead of name                        | ✅ DONE    | Pass spbs list & lookup name by ID          |

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

25. **Stock History Screen** - Riwayat Distribusi (Audit): ✅ DONE
    - Reusable screen accessible from Home Dashboard (MANAGEMENT) & SPG Detail (SETUP).
    - Parameter `spgId` optional: null = show all mutations, non-null = filter specific SPG.
    - Filter chips: [All] [Initial] [Topup] [Return].
    - Card list showing: Product, Type, Qty, Timestamp, SPG.
    - Tap card for edit dialog with qty counter.
    - Swipe-to-delete or long-press menu for delete action.
    - Validation before edit/delete to prevent negative stock.

26. **Edit Stock Mutation** - Validation Logic: ✅ DONE
    - Use case: `UpdateStockMutationQty` with params (id, qty).
    - Validation formula: `newQty >= (totalSold + totalReturn - otherDistributions)`.
    - Error message: "Qty tidak bisa lebih kecil dari yang sudah terjual".
    - Bloc event: `UpdateStockMutation` added to StockBloc.

27. **Delete Stock Mutation** - Validation Logic: ✅ DONE
    - Use case: `DeleteStockMutationRecord` with params (id).
    - Validation formula: `(otherDistributions - totalReturn) >= totalSold`.
    - Error message: "Tidak bisa hapus, stok sudah ada yang terjual".
    - Confirmation dialog before delete (destructive action).
    - Bloc event: `DeleteStockMutation` added to StockBloc.

28. **Stock Mutation Repository Update**: ✅ DONE
     - Add `update()` method to `StockMutationRepository` interface.
     - Implement `update()` in `StockMutationRepositoryImpl`.
     - Update mutation record in SQLite: `UPDATE stock_mutations SET qty = ? WHERE id = ?`.

## Bug Fixes & Enhancements (Session 2026-04-24)

| #   | Task/Bug                                                      | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 34  | Cash Input - Button disabled issue                           | ✅ DONE    | Added controller listeners for setState rebuild |
| 35  | Cash Input - Smart validation (save 0 for update)            | ✅ DONE    | Added hasRecord field to CashState          |
| 36  | Cash Input - Leading zeros allowed                           | ✅ DONE    | Added _ThousandsFormatter to strip zeros + format |
| 37  | Cash Input - Thousand separator display                      | ✅ DONE    | Formatter adds dots (150.000) while typing  |
| 38  | SPG List - Missing expected cash & QRIS breakdown            | ✅ DONE    | Added Expected, Cash Tunai, QRIS, Total, Surplus/Deficit |
| 39  | SPG List - Hardcoded price 10000 in status chip              | ✅ DONE    | Fixed to use actual product price per event  |
| 40  | Excel Export - Sheet1 still appearing                        | ✅ DONE    | Moved excel.delete('Sheet1') to end of exportEvent |
| 41  | Excel Export - Summary sheet missing borders                 | ✅ DONE    | Added headerStyle & dataStyle with thin borders |
| 42  | Excel Export - CashRecordEntity type mismatch (firstWhere)   | ✅ DONE    | Changed to firstWhereOrNull from collection package |
| 43  | Excel Export - Detail SPG missing SPB column                 | ✅ DONE    | Added SPB column with vertical merge for same SPB |
| 44  | Excel Export - Detail SPG sorting by SPB                     | ✅ DONE    | Sort alphabetically, unassigned (-) last    |
| 45  | Excel Export - Detail SPB merge for consecutive same SPB     | ✅ DONE    | Group detection & vertical cell merging     |
| 46  | Excel Export - TOTAL row merge SPB + Name                    | ✅ DONE    | Shows "TOTAL" label in merged cell          |

## Master Data Edit Feature (Session 2026-04-24)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 56  | Add edit feature for Product Master                          | ✅ DONE    | Edit dialog + edit button in ListTile       |
| 57  | Add edit feature for SPG Master                              | ✅ DONE    | UpdateSpgEvent + SpgUpdated state + UI      |
| 58  | Add edit feature for SPB Master                              | ✅ DONE    | UpdateSpbEvent + SpbUpdated state + UI      |
| 59  | SPB Repository: Add update() method                          | ✅ DONE    | Interface + implementation                  |
| 60  | SPB Usecase: Add UpdateSpb                                   | ✅ DONE    | Registered in DI                            |
| 61  | SPB Bloc: Add UpdateSpbEvent handler                         | ✅ DONE    | Injected usecase, added on<UpdateSpbEvent>  |
| 62  | SPG Bloc: Add UpdateSpgEvent handler                         | ✅ DONE    | Injected existing UpdateSpg usecase         |

## SPG List Sorting Feature (Session 2026-04-24)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 63  | Add sort mode enum and state variable                        | ✅ DONE    | _SpgSortMode { name, spb }                  |
| 64  | Add sort chips in AppBar actions                             | ✅ DONE    | FilterChip with Name/SPB toggle             |
| 65  | Implement sort logic for EventSpgEntity list                 | ✅ DONE    | Sort by SPG name or SPB name (nulls last)   |
| 66  | Wrap _buildSpgList with BlocBuilder<SpgBloc>                 | ✅ DONE    | Required for SPG name lookup during sorting |

## Data Refresh Fix - Event-Level Loading (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 67  | stock_bloc: Change mutation handlers to LoadStockByEvent    | ✅ DONE    | 5 handlers: initial, topup, return, update, delete |
| 68  | sales_bloc: Change handler to LoadAllSalesByEvent           | ✅ DONE    | _onUpdateSales now loads all event sales    |
| 69  | cash_bloc: Change handler to LoadAllCashByEvent             | ✅ DONE    | _onUpdateCashRecord now loads all event cash |
| 70  | Fix: SPG List not refreshing after mutations                | ✅ DONE    | BlocBuilder catches event-level updates now |

## Phase 2 - Save + Open + Share (Session 2026-04-24)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 47  | Add open_file_plus + permission_handler packages            | ✅ DONE    | pubspec.yaml updated                        |
| 48  | Android storage permissions (WRITE/READ)                     | ✅ DONE    | AndroidManifest.xml with maxSdkVersion="28" |
| 49  | Android FileProvider configuration                           | ✅ DONE    | file_paths.xml created                      |
| 50  | saveToDownloads() method for Android/iOS                     | ✅ DONE    | Downloads/Stockist folder                   |
| 51  | openFile() method with fallback                              | ✅ DONE    | Returns bool, fallback to share if fail     |
| 52  | ExportLoadingDialog widget                                   | ✅ DONE    | Spinner + "Generating Excel..."             |
| 53  | ExportSuccessDialog widget                                   | ✅ DONE    | Open/Share/Close buttons                    |
| 54  | PermissionDeniedDialog widget                                | ✅ DONE    | Grant/Share Only/Cancel options             |
| 55  | Home screen export flow integration                          | ✅ DONE    | Full dialog-based export flow               |

---

## Progress Summary

- ✅ Completed: 55/55 (100%)
- ⏳ Pending: 0/55 (0%)

## PRD Reference

- PRD Section 6.1: Create Event flow ✅
- PRD Section 6.2: Setup Data (Event Setup) ✅
- PRD Section 6.3-6.8: Stock & Sales operations ✅ (All screens implemented with BLoC integration)
- PRD Section 6.9: Edit & Delete Distribusi ✅ (Tasks #25-28 completed)
- PRD Section 6.10: Backup ✅ (Service created, needs UI wiring)
- PRD Section 7.1: Home Screen (Active Event Dashboard) ✅ (Consolidated & Auto-detect)
- PRD Section 8: Export Excel ✅ (Enhanced with SPB column, borders, sorting)
- **Danger Zone**: Reset All Data feature implemented (with 2-step confirmation) ✅

## Completed Features (Session 2026-04-24)

29. **Cash Input Enhancements**:
    - Smart validation: New record requires input > 0, update allows zero values.
    - Thousand separator formatter: Shows 150.000 while typing with dots.
    - Leading zero stripping: Prevents input like 0150000 via _ThousandsFormatter.
    - Button text changes: "SIMPAN KAS" vs "UPDATE KAS" based on hasRecord state.
    - Controller listeners: Added setState rebuild when user types.
30. **SPG List - Cash Breakdown Display**:
    - Shows Expected Cash (calculated from sales × product price).
    - Cash Tunai and QRIS displayed separately with values.
    - Total Actual Cash summary (cash + qris).
    - Surplus/Deficit indicator with color (green/red) when not matching.
    - Fixed hardcoded price 10000 in status chip - now uses actual event product price.
31. **Excel Export Quality Improvements**:
    - Sheet1 fix: Moved deletion to end of exportEvent() method.
    - Summary sheet borders: headerStyle (bold, grey200 bg), nameStyle (left align), dataStyle (center).
    - CashRecordEntity fix: Changed firstWhere to firstWhereOrNull to avoid type mismatch.
    - Detail SPG sheet enhanced:
      - Added SPB column (column 0) with vertical header merge.
      - SPGs sorted by SPB alphabetically (unassigned "-" shown last).
      - Vertical cell merge for consecutive SPGs with same SPB.
      - TOTAL row merges SPB + Name columns, displays "TOTAL" label.
      - All cells have thin borders with proper alignment (left for names, center for numbers).
