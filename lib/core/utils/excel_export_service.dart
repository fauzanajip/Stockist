import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';
import '../../../domain/entities/event_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/entities/sales_entity.dart';
import '../../../domain/entities/cash_record_entity.dart';

/// Excel export service for generating reports per event
class ExcelExportService {
  ExcelExportService._();

  /// Export event data to Excel file
  static Future<String> exportEvent({
    required EventEntity event,
    required List<EventSpgEntity> eventSpgs,
    required List<SpgEntity> spgs,
    required List<EventProductEntity> eventProducts,
    required List<ProductEntity> products,
    required List<StockMutationEntity> stockMutations,
    required List<SalesEntity> sales,
    required List<CashRecordEntity> cashRecords,
  }) async {
    final excel = Excel.createExcel();

    _createSummarySheet(
      excel,
      event: event,
      eventSpgs: eventSpgs,
      spgs: spgs,
      eventProducts: eventProducts,
      products: products,
      stockMutations: stockMutations,
      sales: sales,
      cashRecords: cashRecords,
    );

    _createDetailSheets(
      excel,
      event: event,
      eventSpgs: eventSpgs,
      spgs: spgs,
      eventProducts: eventProducts,
      products: products,
      stockMutations: stockMutations,
      sales: sales,
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${event.name}_${DateFormat('yyyy-MM-dd').format(event.date)}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// Share Excel file via Android Share Sheet
  static Future<void> shareExcel(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: 'Laporan Event Stockist');
  }

  static void _createSummarySheet(
    Excel excel, {
    required EventEntity event,
    required List<EventSpgEntity> eventSpgs,
    required List<SpgEntity> spgs,
    required List<EventProductEntity> eventProducts,
    required List<ProductEntity> products,
    required List<StockMutationEntity> stockMutations,
    required List<SalesEntity> sales,
    required List<CashRecordEntity> cashRecords,
  }) {
    final sheet = excel['Ringkasan Event'];
    
    // Headers
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    ).value = TextCellValue('SPG');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
    ).value = TextCellValue('Total Dikasih');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
    ).value = TextCellValue('Total Terjual');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    ).value = TextCellValue('Sisa Sistem');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
    ).value = TextCellValue('Cash Tunai');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
    ).value = TextCellValue('QRIS');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0),
    ).value = TextCellValue('Expected Cash');
    
    sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
    ).value = TextCellValue('Surplus');

    // Data rows - one per SPG
    for (int i = 0; i < eventSpgs.length; i++) {
      final eventSpg = eventSpgs[i];
      final spg = spgs.firstWhere((s) => s.id == eventSpg.spgId);
      
      final totalDikasih = _calculateTotalGiven(eventId: event.id, spgId: spg.id, mutations: stockMutations);
      final totalTerjual = _calculateTotalSold(eventId: event.id, spgId: spg.id, sales: sales);
      final sisaSistem = totalDikasih - totalTerjual;
      
      final cashRecord = cashRecords.firstWhere(
        (c) => c.spgId == spg.id,
        orElse: () => CashRecordEntity(
          id: '',
          eventId: event.id,
          spgId: spg.id,
          cashReceived: 0,
          qrisReceived: 0,
        ),
      );
      
      final expectedCash = _calculateExpectedCash(
        eventProducts: eventProducts,
        sales: sales,
        spgId: spg.id,
      );
      
      final actualCash = cashRecord.cashReceived + cashRecord.qrisReceived;
      final surplus = actualCash - expectedCash;

      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
      ).value = TextCellValue(spg.name);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1),
      ).value = IntCellValue(totalDikasih);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1),
      ).value = IntCellValue(totalTerjual);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1),
      ).value = IntCellValue(sisaSistem);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1),
      ).value = DoubleCellValue(cashRecord.cashReceived);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1),
      ).value = DoubleCellValue(cashRecord.qrisReceived);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1),
      ).value = DoubleCellValue(expectedCash);
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1),
      ).value = DoubleCellValue(surplus);
    }
  }

  static void _createDetailSheets(
    Excel excel, {
    required EventEntity event,
    required List<EventSpgEntity> eventSpgs,
    required List<SpgEntity> spgs,
    required List<EventProductEntity> eventProducts,
    required List<ProductEntity> products,
    required List<StockMutationEntity> stockMutations,
    required List<SalesEntity> sales,
  }) {
    // Create one sheet per SPG
    for (int i = 0; i < eventSpgs.length; i++) {
      final eventSpg = eventSpgs[i];
      final spg = spgs.firstWhere((s) => s.id == eventSpg.spgId);
      final sheetName = spg.name.length > 30 ? spg.name.substring(0, 30) : spg.name;
      
      // Get existing sheet and rename
      final sheetKey = excel.sheets.keys.elementAt(0);
      final sheet = excel.sheets[sheetKey]!;
      
      // Headers
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      ).value = TextCellValue('Produk');
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      ).value = TextCellValue('AWAL');
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
      ).value = TextCellValue('TAMBAH');
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
      ).value = TextCellValue('RETURN');
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
      ).value = TextCellValue('TERJUAL');
      
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
      ).value = TextCellValue('SISA');

      // Data rows - one per product
      for (int i = 0; i < eventProducts.length; i++) {
        final eventProduct = eventProducts[i];
        final product = products.firstWhere((p) => p.id == eventProduct.productId);
        
        final initial = _calculateInitial(eventId: event.id, spgId: spg.id, productId: product.id, mutations: stockMutations);
        final topup = _calculateTopup(eventId: event.id, spgId: spg.id, productId: product.id, mutations: stockMutations);
        final returnQty = _calculateReturn(eventId: event.id, spgId: spg.id, productId: product.id, mutations: stockMutations);
        final sold = _calculateSold(eventId: event.id, spgId: spg.id, productId: product.id, sales: sales);
        final sisa = (initial + topup - returnQty) - sold;

        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1),
        ).value = TextCellValue(product.name);
        
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1),
        ).value = IntCellValue(initial);
        
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1),
        ).value = IntCellValue(topup);
        
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1),
        ).value = IntCellValue(returnQty);
        
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1),
        ).value = IntCellValue(sold);
        
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1),
        ).value = IntCellValue(sisa);
      }
    }
  }

  static int _calculateTotalGiven({
    required String eventId,
    required String spgId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where((m) => 
            m.eventId == eventId && 
            m.spgId == spgId && 
            (m.type == MutationType.initial || m.type == MutationType.topup))
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateTotalSold({
    required String eventId,
    required String spgId,
    required List<SalesEntity> sales,
  }) {
    return sales
        .where((s) => s.eventId == eventId && s.spgId == spgId)
        .fold(0, (sum, s) => sum + s.qtySold);
  }

  static double _calculateExpectedCash({
    required List<EventProductEntity> eventProducts,
    required List<SalesEntity> sales,
    required String spgId,
  }) {
    double total = 0;
    for (final sale in sales.where((s) => s.spgId == spgId)) {
      final eventProduct = eventProducts.firstWhere(
        (ep) => ep.productId == sale.productId,
        orElse: () => EventProductEntity(
          id: '',
          eventId: sale.eventId,
          productId: sale.productId,
          price: 0,
        ),
      );
      total += sale.qtySold * eventProduct.price;
    }
    return total;
  }

  static int _calculateInitial({
    required String eventId,
    required String spgId,
    required String productId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where((m) => 
            m.eventId == eventId && 
            m.spgId == spgId && 
            m.productId == productId && 
            m.type == MutationType.initial)
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateTopup({
    required String eventId,
    required String spgId,
    required String productId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where((m) => 
            m.eventId == eventId && 
            m.spgId == spgId && 
            m.productId == productId && 
            m.type == MutationType.topup)
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateReturn({
    required String eventId,
    required String spgId,
    required String productId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where((m) => 
            m.eventId == eventId && 
            m.spgId == spgId && 
            m.productId == productId && 
            m.type == MutationType.returnMutation)
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateSold({
    required String eventId,
    required String spgId,
    required String productId,
    required List<SalesEntity> sales,
  }) {
    try {
      final sale = sales.firstWhere(
        (s) => s.eventId == eventId && s.spgId == spgId && s.productId == productId,
      );
      return sale.qtySold;
    } catch (e) {
      return 0;
    }
  }
}
