/// Core business logic calculations for stock and cash reconciliation
class StockCalculator {
  StockCalculator._();

  /// Calculate total stock given (initial + topup)
  static int calculateTotalGiven({
    required int initialQty,
    required int topupQty,
  }) {
    return initialQty + topupQty;
  }

  /// Calculate total return
  static int calculateTotalReturn({required int returnQty}) {
    return returnQty;
  }

  /// Calculate remaining system stock
  /// sisa_system = (total_dikasih - total_return) - total_terjual
  static int calculateSisaSystem({
    required int totalDikasih,
    required int totalReturn,
    required int totalTerjual,
  }) {
    return (totalDikasih - totalReturn) - totalTerjual;
  }

  /// Calculate expected cash from sales
  /// expected_cash = total_terjual × event_product.price
  static double calculateExpectedCash({
    required int totalTerjual,
    required double pricePerUnit,
  }) {
    return totalTerjual * pricePerUnit;
  }

  /// Calculate actual cash received
  /// actual_cash = cash_received + qris_received
  static double calculateActualCash({
    required double cashReceived,
    required double qrisReceived,
  }) {
    return cashReceived + qrisReceived;
  }

  /// Calculate surplus/deficit
  /// surplus = actual_cash - expected_cash
  static double calculateSurplus({
    required double actualCash,
    required double expectedCash,
  }) {
    return actualCash - expectedCash;
  }

  /// Calculate physical stock difference
  /// selisih_fisik = sisa_system - sisa_real
  static int calculateSelisihFisik({
    required int sisaSystem,
    required int sisaReal,
  }) {
    return sisaSystem - sisaReal;
  }

  /// Determine closing status
  /// ✅ = selisih_fisik == 0 AND surplus == 0
  /// ⚠️ = ada selisih stok ATAU selisih cash
  static String determineClosingStatus({
    required int selisihFisik,
    required double surplus,
    required bool hasAllSalesData,
    required bool hasCashData,
  }) {
    if (!hasAllSalesData || !hasCashData) {
      return '⚠️'; // Belum lengkap
    }
    if (selisihFisik == 0 && surplus == 0) {
      return '✅'; // Selesai sempurna
    }
    return '⚠️'; // Ada selisih
  }
}
