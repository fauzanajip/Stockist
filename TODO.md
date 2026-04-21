# TODO List - Stockist App

## High Priority - Screen Implementation

| #   | Task                                                          | Status     | File                               |
| --- | ------------------------------------------------------------- | ---------- | ---------------------------------- |
| 1   | Implement Create Event Screen - call bloc                     | ✅ DONE    | `create_event_screen.dart`         |
| 2   | Implement Event Setup Screen - assign produk & SPG            | ✅ DONE    | `event_setup_screen.dart`          |
| 3   | Implement SPG List Screen with dashboard view (PRD 7.1)       | ✅ DONE    | `spg_list_screen.dart`             |
| 4   | Implement Initial Distribution Screen - input qty per product | ✅ DONE    | `initial_distribution_screen.dart` |
| 5   | Implement Topup Screen - add stock to SPG                     | ⏳ Pending | `topup_screen.dart`                |
| 6   | Implement Return Screen - return stock from SPG               | ⏳ Pending | `return_screen.dart`               |
| 7   | Implement Sales Input Screen - update qty_sold per product    | ⏳ Pending | `sales_input_screen.dart`          |
| 8   | Implement Cash Input Screen - cash_received + qris_received   | ⏳ Pending | `cash_input_screen.dart`           |
| 9   | Implement Closing Screen with summary table & validation      | ⏳ Pending | `spg_closing_screen.dart`          |
| 10  | Global Event Stock Tracking (Stock from Distributor)          | ✅ DONE    | `event_setup_screen.dart`          |

## Medium Priority - Features

| #   | Task                                                          | Status  | Notes                                       |
| --- | ------------------------------------------------------------- | ------- | ------------------------------------------- |
| 11  | Add business logic calculations (total_dikasih, surplus, etc) | ✅ DONE | `stock_calculator.dart` - PRD Section 5     |
| 12  | Implement Export Excel functionality                          | ✅ DONE | Fully integrated in `EventDetailScreen`     |
| 13  | Implement Backup JSON (Export database)                       | ✅ DONE | `backup_service.dart` - PRD Section 6.9     |
| 14  | Implement Restore JSON (Import backup)                        | ✅ DONE | `backup_service.dart` - PRD Section 6.9     |
| 15  | Settings Screen - Master Data Management                      | ✅ DONE | Add Product, SPG, SPB with BLoC integration |

## Low Priority - Bloc Fixes

| #   | Task                                                     | Status     | Location                |
| --- | -------------------------------------------------------- | ---------- | ----------------------- |
| 16  | Fix StockBloc error states                               | ✅ DONE    | Lines 39, 60, 81, 94    |
| 17  | Fix SPGBloc implementation                               | ✅ DONE    | Lines 16, 24            |
| 18  | Fix SalesBloc error states                               | ⏳ Pending | Lines 33, 49            |
| 19  | Fix CashBloc error states                                | ⏳ Pending | Lines 34, 52            |
| 20  | Fix ProductBloc implementation                           | ✅ DONE    | Lines 16, 24            |
| 21  | Add status indicators (READY/REVIEW) based on data match    | ✅ DONE    | SpgList & SpgDetail     |

---

## Progress Summary

- ✅ Completed: 17/21 (81%)
- ⏳ Pending: 4/21 (19%)

## PRD Reference

- PRD Section 6.1: Create Event flow ✅
- PRD Section 6.2: Setup Data (Event Setup) ✅
- PRD Section 6.3-6.8: Stock & Sales operations ⏳ (UI done, missing BLoC integration)
- PRD Section 7.1: Home Screen Dashboard ✅ (Now with per-product detailed stats)
- PRD Section 8: Export Excel ✅ (Fully integrated and functional)
- PRD Section 6.9: Backup ✅ (Service created, needs UI wiring)

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
   - Save setup button that navigates to event detail
7. **Home Screen** - Event list with BlocBuilder:
   - Display all events from database
   - Empty state if no events
   - Navigate to event detail on tap
   - Settings icon in app bar
8. **SPG List Screen** - Dashboard view per SPG with:
   - Total dikasih, terjual, sisa calculations
   - Cash received display
   - Status indicator (✅/⚠️) based on surplus/selisih
   - Navigate to SPG detail on tap
9. **Settings Screen** - Master Data Management with 3 tabs:
   - Tab Produk: Add product (name, SKU, default price), list all products, soft delete
   - Tab SPG: Add SPG (name), list all SPGs, soft delete
   - Tab SPB: Add SPB (name), list all SPBs, delete
10. **Bloc Providers** - Added all blocs to MultiBlocProvider in main.dart
11. **SpbBloc** - New bloc for SPB management (LoadAll, Create, Delete)
12. **UpdateEventProductPrice Use Case** - Added for dynamic price updates
13. **Router** - Added /settings route for master data management
14. **SPG Dashboard Optimization (Task 4 context)**:
    - Implemented **Batch Loading Architecture**: Loads all event data (Stock, Sales, Cash) in one go to prevent race conditions.
    - Added **Per-Product Detailed Tracking**: Collapsible breakdown showing Distributed, Sold, and Remaining for every product.
    - **Premium UI Overhaul**: Upgraded `SpgListScreen` and `SpgDetailScreen` to a modern dashboard aesthetic with accent bars, dynamic avatars, and professional status chips.
    - **Status Chips (READY/REVIEW)**: Automated validation logic for cash against expected sales.
    - **Visual Unity**: Ensured all screens across the event management flow share the same premium dark mode aesthetic.
16. **Event Setup Overhaul (Search, Draft & Integrity)**:
    - **Draft & Save**: Implemented in-memory drafting for Event Setup, so changes are only committed to the DB on "Simpan Setup".
    - **Searchable UI**: Added search capability (Names & SKU) and "Show Active Only" filters for handling large datasets.
    - **History Guard**: Prevented unassigning Products/SPGs if transactions exist for data integrity.
    - **Warehouse Stock Sync**: Dynamic delta-based stock updates for Global Event Stock.
17. **Home Screen Optimization**:
    - **Reactivity Fix**: Converted to StatefulWidget with automatic `LoadAllEvents` on init.
    - **Pull-to-Refresh**: Added RefreshIndicator for manual data syncing.
    - **State Guard**: Improved handling of initial loading states to prevent flickering or false empty states.
