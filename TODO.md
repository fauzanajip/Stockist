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

## Tactical UI System (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 56  | Industrial Precision Theme Overhaul                          | ✅ DONE    | Zero radius, All-caps w900 typography       |
| 57  | Migrasi Dialog Master Data ke BottomSheets                  | ✅ DONE    | SpgMaster, ProductMaster, SpbMaster         |
| 58  | Refactor Global Theme enforcing tactical style               | ✅ DONE    | `app_theme.dart` updated                    |
| 59  | Fix Syntax & Duplication in `SpgListScreen`                  | ✅ DONE    | Cleaned up manifest duplication             |

## Sales Target Feature (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 60  | Data Layer: `spg_product_targets` table + migration          | ✅ DONE    | Database v3, BulkInitialParams class        |
| 61  | Domain Layer: 7 usecases + DI registration                   | ✅ DONE    | BulkCreateOrUpdate, GetByEventSpgProduct    |
| 62  | Bloc Layer: SpgTargetBloc (event, state, bloc)               | ✅ DONE    | Added to main.dart                          |
| 63  | UI: SalesTargetScreen with Batch Configuration dialog        | ✅ DONE    | Industrial Precision design                 |
| 64  | Target Progress display in SPG List (collapsed ExpansionTile)| ✅ DONE    | Red/Yellow/Green color coding               |
| 65  | Target columns in Closing Screen table                       | ✅ DONE    | Target + Progress % columns                 |

## Bulk Initial Distribution Feature (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 66  | Data Layer: BulkInitialParams + bulkCreateOrUpdateInitial    | ✅ DONE    | Upsert logic, qty=0 = delete record         |
| 67  | Domain Layer: UseCases + warehouse stock helpers             | ✅ DONE    | GetWarehouseStockByProduct, GetDistributed  |
| 68  | Bloc Layer: BulkCreateOrUpdateInitialDistributionEvent       | ✅ DONE    | StockBloc handler                           |
| 69  | UI: BulkInitialDistributionScreen                            | ✅ DONE    | Industrial Precision, SELECT_ALL toggle     |
| 70  | Real-time validation: EXCEEDS warning + disable COMMIT       | ✅ DONE    | Warehouse limit per product per SPG         |
| 71  | Route + Menu tile in Event Dashboard                         | ✅ DONE    | `/event/:eventId/bulk_initial`              |

## UI Fixes (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 72  | Event Dashboard PRODUCT TELEMETRY: IN/DIS/SOLD columns       | ✅ DONE    | IN = warehouse remaining, DIS = distributed |

## Bulk Topup (RESUPPLY) Feature (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 73  | Bloc: BulkCreateTopupEvent + handler (additive, not upsert)  | ✅ DONE    | Creates new topup records, skips qty=0      |
| 74  | UI: BulkTopupScreen with Industrial Precision                 | ✅ DONE    | Title "RESUPPLY", Secondary color           |
| 75  | Success BottomSheet after save                               | ✅ DONE    | Shows SPG/product/qty summary + total       |
| 76  | Route: /event/:eventId/bulk_topup                            | ✅ DONE    | Added to app_router.dart                    |
| 77  | Menu: RESUPPLY tile in Event Dashboard                        | ✅ DONE    | Icon: add_circle_outline, Color: Secondary  |

## Backup/Restore Fix (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 78  | Add file_picker package for import                           | ✅ DONE    | v8.3.7 installed                            |
| 79  | BackupService.exportBackup: add spg_product_targets table    | ✅ DONE    | Both global & event-specific export         |
| 80  | BackupService.importBackup: complete all tables with delete-existing | ✅ DONE | Global backup replaces all; Event backup replaces event data only |
| 81  | BackupScreen: connect buttons to BackupService               | ✅ DONE    | Export button → exportBackup(), Import → file_picker + importBackup() |
| 82  | BackupScreen: add confirm dialog before import               | ✅ DONE    | DATA_OVERRIDE_PROTOCOL warning dialog       |
| 83  | BackupScreen: add success/error SnackBar feedback            | ✅ DONE    | DATA_EXFILTRATION_COMPLETE / DATA_INFILTRATION_COMPLETE |

## Sales Import from Excel (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 84  | ExcelImportService: parse xlsx/csv Transaction Report        | ✅ DONE    | Extract Name/Product/Qty columns            |
| 85  | Domain Layer: BulkSalesItem class + BulkReplaceSales usecase | ✅ DONE    | Delete existing + create new sales records  |
| 86  | Data Layer: SalesRepository.deleteByEvent()                  | ✅ DONE    | Clear sales before bulk insert              |
| 87  | Bloc Layer: BulkReplaceSalesEvent + handler                  | ✅ DONE    | SalesBloc with bulk replace logic           |
| 88  | DI: Register BulkReplaceSales usecase                        | ✅ DONE    | dependency_injection.dart                   |
| 89  | UI: ImportSalesPreviewScreen with mapping                    | ✅ DONE    | Auto-match + manual fix via BottomSheet    |
| 90  | Picker BottomSheets: SPG/Product selection dialogs           | ✅ DONE    | Industrial Precision style, check icon      |
| 91  | Route: /event/:eventId/import_sales_preview                  | ✅ DONE    | app_router.dart with extra param            |
| 92  | Menu: IMPORT SALES tile in Event Dashboard                   | ✅ DONE    | Icon: upload_file_outlined, Color: tertiary |
| 93  | Fix: Track last SPG name for merged cells                    | ✅ DONE    | Excel rows use previous SPG if empty        |
| 94  | Fix: EventDashboardView reload data per event                | ✅ DONE    | Convert to StatefulWidget, initState loads blocs |
| 95  | Fix: Auto-match trim DB names before compare                 | ✅ DONE    | s.name.trim().toUpperCase() comparison      |
| 96  | Fix: setState after auto-match for bottom bar                | ✅ DONE    | PostFrameCallback triggers rebuild          |

## Cash Import from Excel (Session 2026-04-25)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 97  | ExcelImportService: extract Cash per unique SPG              | ✅ DONE    | Dedupe by SPG name, Total Cash + Total Non-Cash (QRIS) |
| 98  | CashImportItem class: spgName, cashReceived, qrisReceived    | ✅ DONE    | TransactionImportResult returns both sales + cash |
| 99  | Domain Layer: BulkUpsertCashItem + BulkUpsertCash usecase    | ✅ DONE    | Upsert mode (update if exists, create if new) |
| 100 | Bloc Layer: BulkUpsertCashEvent + handler                    | ✅ DONE    | CashBloc with bulk upsert logic             |
| 101 | DI: Register BulkUpsertCash usecase                          | ✅ DONE    | dependency_injection.dart                   |
| 102 | UI: Cash Summary section in Preview Screen                   | ✅ DONE    | Shows Cash/QRIS per SPG + totals            |
| 103 | UI: Execute Sales then Cash sequentially                     | ✅ DONE    | SalesBloc listener triggers CashBloc import |
| 104 | UI: Loading indicator shows "SALES..." or "CASH..."          | ✅ DONE    | Conditional text based on saving state      |

## Pending Topup System (Session 2026-04-26)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 105 | Data Layer: pending_topups table + migration (v4)           | ✅ DONE    | Fields: id, event_id, spb_id, spg_id, product_id, qty, type, is_checked, stock_mutation_id |
| 106 | Entity: PendingTopupEntity with type enum (initial/topup)    | ✅ DONE    | pending_topup_entity.dart                   |
| 107 | Model: PendingTopupModel with fromMap/toMap/fromEntity      | ✅ DONE    | pending_topup_model.dart                    |
| 108 | Repository: PendingTopupRepository interface + impl         | ✅ DONE    | CRUD + getByEvent + getByEventAndSpb        |
| 109 | EventSpgRepository: Add getSpbIdBySpg(eventId, spgId)        | ✅ DONE    | Lookup SPB for auto-topup from other menus  |
| 110 | Domain: 6 usecases (GetByEvent, GetBySpb, Create, Update, Delete, GetById) | ✅ DONE | pending_topup_usecases.dart                 |
| 111 | Bloc: PendingTopupBloc with toggle checkbox logic           | ✅ DONE    | Toggle creates/deletes stock mutation       |
| 112 | StockBloc: Modify handlers to create pending_topups         | ✅ DONE    | CreateInitial, BulkInitial, CreateTopup, BulkTopup all create pending_topup entries |
| 113 | UI: StockDistributionScreen with responsive layout          | ✅ DONE    | Web: left-right, Mobile: tabs               |
| 114 | History table: TYPE/SPB columns + disabled checkbox for INITIAL | ✅ DONE | Checkbox disabled for type=initial          |
| 115 | Add form: SPB dropdown → SPG dropdown (filtered) → Product  | ✅ DONE    | DropdownButtonFormField with type annotations |
| 116 | Stock info panel: SPG stock + Warehouse available           | ✅ DONE    | Real-time calculation on selection          |
| 117 | Product dropdown: stock badge ("WH: XX" or "OUT OF STOCK")  | ✅ DONE    | Color indicator for out-of-stock            |
| 118 | Quick actions: INITIAL DISTRIBUTION + RESUPPLY buttons      | ✅ DONE    | Navigate to bulk screens                    |
| 119 | Route + Menu: STOCK DISTRIBUTION replaces INITIAL/RESUPPLY  | ✅ DONE    | Unified hub in Event Dashboard              |

## Master Data Batch Import (Session 2026-04-26)

| #   | Task                                                         | Status     | Notes                                       |
| --- | ------------------------------------------------------------ | ---------- | ------------------------------------------- |
| 120 | Bloc: BatchCreateSpbsEvent + handler                         | ✅ DONE    | Batch creation for SPB master               |
| 121 | Bloc: BatchCreateSpgsEvent + handler                         | ✅ DONE    | Batch creation for SPG master               |
| 122 | Bloc: BatchCreateProductsEvent + handler                     | ✅ DONE    | Batch creation for Product master           |
| 123 | Repository: Duplicate name validation (case-insensitive)     | ✅ DONE    | Check before insert, throw DuplicateException |
| 124 | ExcelImportService: Template generation + parsing            | ✅ DONE    | Generate .xlsx template, parse import file   |
| 125 | UI: Batch entry form with animated list                      | ✅ DONE    | Add/remove rows, error display              |
| 126 | UI: Import from Excel button + file picker                   | ✅ DONE    | Import flow with duplicate validation       |

## Completed Features (Summary)

1. StockCalculator - all business logic calculations
2. ExcelExportService - multi-sheet export with summary + detail sheets
3. BackupService - export/import JSON via Android Share Sheet
4. All placeholder screens created with Industrial Brutalism dark mode design
5. **Create Event Screen** - Full BLoC integration.
6. **Event Setup Screen** - Full implementation with tab navigation.
7. **Home Screen (Dashboard-First)**: Integrated EventDashboardView.
8. **Architecture Consolidation**: Removed EventDetailScreen.
9. **SPG List Screen** - Dashboard view per SPG.
10. **Settings Screen** - Master Data Management with 3 tabs.
11. **SPG Dashboard Optimization**: Collapsible breakdown per product.
12. **Event Setup Overhaul**: Search, Draft & Integrity.
13. **Reset All Data**: Danger Zone recovery.
14. **Topup & Return Screens**: Full BLoC integration with validation.
15. **Sales & Cash Input**: Revenue capture with thousand separators.
16. **Closing Screen**: Full reconciliation table.
17. **Stock History (Audit)**: Riwayat Mutasi with edit/delete.
18. **Save + Open + Share**: Full Excel export workflow.
19. **Industrial Precision Overhaul**: Tactical "Command Center" aesthetic across all screens.
20. **Sales Import from Excel**: Import external Transaction Report with preview & mapping UI.
21. **Pending Topup System**: Unified stock distribution hub with pending/processed tracking.
22. **Master Data Batch Import**: Batch creation + duplicate validation + Excel import.

---

## Progress Summary

- ✅ Completed: 126/126 (100%)
- ⏳ Pending: 0/126 (0%)

## PRD Reference

- PRD Section 6.1: Create Event flow ✅
- PRD Section 6.2: Setup Data (Event Setup) ✅
- PRD Section 6.3-6.8: Stock & Sales operations ✅
- PRD Section 6.9: Edit & Delete Distribusi ✅
- PRD Section 6.10: Local Backup ✅
- PRD Section 6.11: Stock Distribution Hub (Pending Topup System) ✅
- PRD Section 6.12: Master Data Batch Import ✅
- PRD Section 7.1: Home Screen (Active Event Dashboard) ✅
- PRD Section 8: Export Excel ✅
- **Design System**: Industrial Precision Tactical UI ✅
- **Sales Target**: Per-SPG per-product target qty with progress tracking ✅
- **Bulk Initial Distribution**: Upsert warehouse-limited initial stock ✅
- **Sales Import**: Import sales data from external Excel/CSV with preview & mapping ✅
- **Pending Topup System**: Unified hub with toggle checkbox ✅
- **Master Data Batch Import**: Batch creation + Excel import ✅
