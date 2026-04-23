import 'dart:io';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';
import '../../../domain/entities/event_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/spb_entity.dart';
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
    required List<SpbEntity> spbs,
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
      spbs: spbs,
      eventProducts: eventProducts,
      products: products,
      stockMutations: stockMutations,
      sales: sales,
    );

    excel.delete('Sheet1');

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${event.name}_${DateFormat('yyyy-MM-dd').format(event.date)}.xlsx';
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

  /// Save file to Downloads/Stockist folder
  static Future<String?> saveToDownloads(
    String sourceFilePath,
    String fileName,
  ) async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await _checkAndroidStoragePermission();
        if (!hasPermission) {
          return null;
        }

        final downloadsDir = Directory('/storage/emulated/0/Download/Stockist');
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }

        final destPath = p.join(downloadsDir.path, fileName);
        final sourceFile = File(sourceFilePath);
        await sourceFile.copy(destPath);

        return destPath;
      } else if (Platform.isIOS) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final stockistDir = Directory(p.join(appDocDir.path, 'Stockist'));
        if (!stockistDir.existsSync()) {
          stockistDir.createSync(recursive: true);
        }

        final destPath = p.join(stockistDir.path, fileName);
        final sourceFile = File(sourceFilePath);
        await sourceFile.copy(destPath);

        return destPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check Android storage permission (Android 9 and below)
  static Future<bool> _checkAndroidStoragePermission() async {
    if (Platform.isAndroid) {
      final info = await Permission.storage.status;
      if (info.isGranted) {
        return true;
      }

      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return true;
  }

  /// Open file with default app
  static Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      return false;
    }
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

    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.black,
    );

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.grey200,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    final dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    final nameStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    // Headers
    final headers = [
      'SPG',
      'Total Dikasih',
      'Total Terjual',
      'Total Return',
      'Sisa Sistem',
      'Cash Tunai',
      'QRIS',
      'Expected Cash',
      'Surplus',
    ];

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // Data rows - one per SPG
    for (int i = 0; i < eventSpgs.length; i++) {
      final eventSpg = eventSpgs[i];
      final spg = spgs.firstWhere((s) => s.id == eventSpg.spgId);

      final totalDikasih = _calculateTotalGiven(
        eventId: event.id,
        spgId: spg.id,
        mutations: stockMutations,
      );
      final totalTerjual = _calculateTotalSold(
        eventId: event.id,
        spgId: spg.id,
        sales: sales,
      );
      final totalReturn = _calculateTotalReturnQty(
        eventId: event.id,
        spgId: spg.id,
        mutations: stockMutations,
      );
      final sisaSistem = totalDikasih - totalReturn - totalTerjual;

      final cashRecord = cashRecords.firstWhereOrNull((c) => c.spgId == spg.id);
      final cashReceived = cashRecord?.cashReceived ?? 0;
      final qrisReceived = cashRecord?.qrisReceived ?? 0;

      final expectedCash = _calculateExpectedCash(
        eventProducts: eventProducts,
        sales: sales,
        spgId: spg.id,
      );

      final actualCash = cashReceived + qrisReceived;
      final surplus = actualCash - expectedCash;

      final values = [
        TextCellValue(spg.name),
        IntCellValue(totalDikasih),
        IntCellValue(totalTerjual),
        IntCellValue(totalReturn),
        IntCellValue(sisaSistem),
        DoubleCellValue(cashReceived),
        DoubleCellValue(qrisReceived),
        DoubleCellValue(expectedCash),
        DoubleCellValue(surplus),
      ];

      for (int col = 0; col < values.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1),
        );
        cell.value = values[col];
        cell.cellStyle = col == 0 ? nameStyle : dataStyle;
      }
    }
  }

  static void _createDetailSheets(
    Excel excel, {
    required EventEntity event,
    required List<EventSpgEntity> eventSpgs,
    required List<SpgEntity> spgs,
    required List<SpbEntity> spbs,
    required List<EventProductEntity> eventProducts,
    required List<ProductEntity> products,
    required List<StockMutationEntity> stockMutations,
    required List<SalesEntity> sales,
  }) {
    final sheet = excel['Detail SPG'];

    final border = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.black,
    );

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    final dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    final nameStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    final sumStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.grey200,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );

    // Sort SPGs by SPB (alphabetically, unassigned last)
    final sortedEventSpgs = eventSpgs.toList();
    sortedEventSpgs.sort((a, b) {
      final spbA = a.spbId != null
          ? spbs.firstWhereOrNull((s) => s.id == a.spbId)?.name ?? ''
          : '';
      final spbB = b.spbId != null
          ? spbs.firstWhereOrNull((s) => s.id == b.spbId)?.name ?? ''
          : '';

      if (spbA.isEmpty && spbB.isNotEmpty) return 1;
      if (spbA.isNotEmpty && spbB.isEmpty) return -1;
      return spbA.compareTo(spbB);
    });

    // Track SPB groups for merging
    final spbGroups = <_SpbGroup>[];
    String? lastSpbName;
    int startRow = 3;
    int count = 0;

    for (int i = 0; i < sortedEventSpgs.length; i++) {
      final eventSpg = sortedEventSpgs[i];
      final spbName = eventSpg.spbId != null
          ? spbs.firstWhereOrNull((s) => s.id == eventSpg.spbId)?.name ?? '-'
          : '-';

      if (i == 0) {
        lastSpbName = spbName;
        count = 1;
      } else if (spbName == lastSpbName && spbName != '-') {
        count++;
      } else {
        if (count > 1 && lastSpbName != '-') {
          spbGroups.add(_SpbGroup(startRow, count));
        }
        startRow = 3 + i;
        lastSpbName = spbName;
        count = 1;
      }
    }
    if (count > 1 && lastSpbName != '-') {
      spbGroups.add(_SpbGroup(startRow, count));
    }

    final totalColumns = 2 + (eventProducts.length * 5);

    // Row 0-2: Headers
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
    );
    final spbHeaderCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    spbHeaderCell.value = TextCellValue('SPB');
    spbHeaderCell.cellStyle = headerStyle;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2),
    );
    final nameHeaderCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
    );
    nameHeaderCell.value = TextCellValue('Name');
    nameHeaderCell.cellStyle = headerStyle;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: totalColumns - 1, rowIndex: 0),
    );
    final productHeaderCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
    );
    productHeaderCell.value = TextCellValue('PRODUCT');
    productHeaderCell.cellStyle = headerStyle;

    int col = 2;
    for (final eventProduct in eventProducts) {
      final product = products.firstWhere(
        (p) => p.id == eventProduct.productId,
      );

      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1),
        CellIndex.indexByColumnRow(columnIndex: col + 4, rowIndex: 1),
      );
      final productCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1),
      );
      productCell.value = TextCellValue(product.name);
      productCell.cellStyle = headerStyle;

      col += 5;
    }

    col = 2;
    for (int prodIdx = 0; prodIdx < eventProducts.length; prodIdx++) {
      for (int i = 0; i < 5; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col + i, rowIndex: 2),
        );
        cell.value = TextCellValue(
          ['AWAL', 'TAMBAH', 'RETURN', 'TERJUAL', 'SISA'][i],
        );
        cell.cellStyle = headerStyle;
      }
      col += 5;
    }

    final sumValues = List<List<int>>.generate(
      eventProducts.length,
      (_) => [0, 0, 0, 0, 0],
    );

    int row = 3;
    for (final eventSpg in sortedEventSpgs) {
      final spg = spgs.firstWhere((s) => s.id == eventSpg.spgId);
      final spbName = eventSpg.spbId != null
          ? spbs.firstWhereOrNull((s) => s.id == eventSpg.spbId)?.name ?? '-'
          : '-';

      final spbCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      );
      spbCell.value = TextCellValue(spbName);
      spbCell.cellStyle = nameStyle;

      final nameCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      nameCell.value = TextCellValue(spg.name);
      nameCell.cellStyle = nameStyle;

      col = 2;
      int prodIndex = 0;
      for (final eventProduct in eventProducts) {
        final product = products.firstWhere(
          (p) => p.id == eventProduct.productId,
        );

        final initial = _calculateInitial(
          eventId: event.id,
          spgId: spg.id,
          productId: product.id,
          mutations: stockMutations,
        );
        final topup = _calculateTopup(
          eventId: event.id,
          spgId: spg.id,
          productId: product.id,
          mutations: stockMutations,
        );
        final returnQty = _calculateReturn(
          eventId: event.id,
          spgId: spg.id,
          productId: product.id,
          mutations: stockMutations,
        );
        final sold = _calculateSold(
          eventId: event.id,
          spgId: spg.id,
          productId: product.id,
          sales: sales,
        );
        final sisa = (initial + topup - returnQty) - sold;

        sumValues[prodIndex][0] += initial;
        sumValues[prodIndex][1] += topup;
        sumValues[prodIndex][2] += returnQty;
        sumValues[prodIndex][3] += sold;
        sumValues[prodIndex][4] += sisa;

        final values = [initial, topup, returnQty, sold, sisa];
        for (int i = 0; i < 5; i++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col + i, rowIndex: row),
          );
          cell.value = IntCellValue(values[i]);
          cell.cellStyle = dataStyle;
        }

        col += 5;
        prodIndex++;
      }

      row++;
    }

    // Merge SPB cells for same SPB groups
    for (final group in spbGroups) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: group.startRow),
        CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: group.startRow + group.count - 1,
        ),
      );
    }

    // TOTAL row
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
    );
    final totalCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    totalCell.value = TextCellValue('TOTAL');
    totalCell.cellStyle = sumStyle;

    col = 2;
    for (int prodIndex = 0; prodIndex < eventProducts.length; prodIndex++) {
      for (int i = 0; i < 5; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col + i, rowIndex: row),
        );
        cell.value = IntCellValue(sumValues[prodIndex][i]);
        cell.cellStyle = sumStyle;
      }
      col += 5;
    }
  }

  static int _calculateTotalGiven({
    required String eventId,
    required String spgId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where(
          (m) =>
              m.eventId == eventId &&
              m.spgId == spgId &&
              (m.type == MutationType.initial || m.type == MutationType.topup),
        )
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

  static int _calculateTotalReturnQty({
    required String eventId,
    required String spgId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where(
          (m) =>
              m.eventId == eventId &&
              m.spgId == spgId &&
              m.type == MutationType.returnMutation,
        )
        .fold(0, (sum, m) => sum + m.qty);
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
        .where(
          (m) =>
              m.eventId == eventId &&
              m.spgId == spgId &&
              m.productId == productId &&
              m.type == MutationType.initial,
        )
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateTopup({
    required String eventId,
    required String spgId,
    required String productId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where(
          (m) =>
              m.eventId == eventId &&
              m.spgId == spgId &&
              m.productId == productId &&
              m.type == MutationType.topup,
        )
        .fold(0, (sum, m) => sum + m.qty);
  }

  static int _calculateReturn({
    required String eventId,
    required String spgId,
    required String productId,
    required List<StockMutationEntity> mutations,
  }) {
    return mutations
        .where(
          (m) =>
              m.eventId == eventId &&
              m.spgId == spgId &&
              m.productId == productId &&
              m.type == MutationType.returnMutation,
        )
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
        (s) =>
            s.eventId == eventId &&
            s.spgId == spgId &&
            s.productId == productId,
      );
      return sale.qtySold;
    } catch (e) {
      return 0;
    }
  }
}

class _SpbGroup {
  final int startRow;
  final int count;

  _SpbGroup(this.startRow, this.count);
}
