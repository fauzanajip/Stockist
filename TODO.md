# TODO List - Stockist App

## High Priority - Screen Implementation

| # | Task | Status | File |
|---|------|--------|------|
| 1 | Implement Create Event Screen - call bloc | ✅ DONE | `create_event_screen.dart` |
| 2 | Implement Event Setup Screen - assign produk & SPG | ✅ DONE | `event_setup_screen.dart` |
| 3 | Implement SPG List Screen with dashboard view (PRD 7.1) | ⏳ Pending | `spg_list_screen.dart` |
| 4 | Implement Initial Distribution Screen - input qty per product | ⏳ Pending | `initial_distribution_screen.dart` |
| 5 | Implement Topup Screen - add stock to SPG | ⏳ Pending | `topup_screen.dart` |
| 6 | Implement Return Screen - return stock from SPG | ⏳ Pending | `return_screen.dart` |
| 7 | Implement Sales Input Screen - update qty_sold per product | ⏳ Pending | `sales_input_screen.dart` |
| 8 | Implement Cash Input Screen - cash_received + qris_received | ⏳ Pending | `cash_input_screen.dart` |
| 9 | Implement Closing Screen with summary table & validation | ⏳ Pending | `spg_closing_screen.dart` |

## Medium Priority - Features

| # | Task | Status | Notes |
|---|------|--------|-------|
| 10 | Add business logic calculations (total_dikasih, surplus, etc) | ⏳ Pending | PRD Section 5 |
| 11 | Implement Export Excel functionality | ⏳ Pending | `event_detail_screen.dart:53` |
| 12 | Implement Backup JSON (Export database) | ⏳ Pending | `backup_screen.dart:51` |
| 13 | Implement Restore JSON (Import backup) | ⏳ Pending | `backup_screen.dart:94` |

## Low Priority - Bloc Fixes

| # | Task | Status | Location |
|---|------|--------|----------|
| 14 | Fix StockBloc error states | ✅ DONE | Lines 39, 60, 81, 94 |
| 15 | Fix SPGBloc implementation | ✅ DONE | Lines 16, 24 |
| 16 | Fix SalesBloc error states | ⏳ Pending | Lines 33, 49 |
| 17 | Fix CashBloc error states | ⏳ Pending | Lines 34, 52 |
| 18 | Fix ProductBloc implementation | ✅ DONE | Lines 16, 24 |
| 19 | Add status indicators (✅/⚠️) based on selisih & surplus | ⏳ Pending | Home screen & SPG cards |

---

## Progress Summary
- ✅ Completed: 5/19 (26%)
- ⏳ Pending: 14/19 (74%)

## PRD Reference
- PRD Section 6.1: Create Event flow ✅
- PRD Section 6.2: Setup Data (Event Setup) ✅
- PRD Section 6.3-6.8: Stock & Sales operations ⏳
- PRD Section 7.1: Home Screen Dashboard ⏳
- PRD Section 8: Export Excel ⏳
- PRD Section 6.9: Backup ⏳