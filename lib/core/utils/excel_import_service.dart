import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class SalesImportItem {
  final String spgName;
  final String productName;
  final int qtySold;

  SalesImportItem({
    required this.spgName,
    required this.productName,
    required this.qtySold,
  });
}

class CashImportItem {
  final String spgName;
  final double cashReceived;
  final double qrisReceived;

  CashImportItem({
    required this.spgName,
    required this.cashReceived,
    required this.qrisReceived,
  });
}

class TransactionImportResult {
  final List<SalesImportItem> salesItems;
  final List<CashImportItem> cashItems;

  TransactionImportResult({
    required this.salesItems,
    required this.cashItems,
  });
}

class ExcelImportService {
  ExcelImportService._();

  static Future<FilePickerResult?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );
    return result;
  }

  static Future<TransactionImportResult> parseTransactionReport(PlatformFile platformFile) async {
    if (platformFile.name.toLowerCase().endsWith('.csv')) {
      return _parseCsv(platformFile);
    }

    final bytes = kIsWeb ? platformFile.bytes! : await File(platformFile.path!).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final salesItems = <SalesImportItem>[];
    final cashItems = <CashImportItem>[];
    final seenSpgNames = <String>{};

    for (final sheetName in excel.tables.keys) {
      final sheet = excel[sheetName];
      if (sheet == null) continue;

      final rows = sheet.rows;

      if (rows.length < 5) continue;

      final headerRow = rows[3];
      final nameColIndex = _findColumnIndex(headerRow, 'Name');
      final productColIndex = _findColumnIndex(headerRow, 'Product');
      final qtyColIndex = _findColumnIndex(headerRow, 'Qty');
      final cashColIndex = _findColumnIndex(headerRow, 'Total Cash');
      final nonCashColIndex = _findColumnIndex(headerRow, 'Total Non-Cash');

      if (nameColIndex == -1 || productColIndex == -1 || qtyColIndex == -1) {
        continue;
      }

      String lastSpgName = '';

      for (int i = 4; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final spgNameRaw = _getCellValue(row[nameColIndex]);
        final productName = _getCellValue(row[productColIndex]);
        final qtyStr = _getCellValue(row[qtyColIndex]);

        if (productName.isEmpty) continue;

        String spgName = spgNameRaw.trim().toUpperCase();
        if (spgName.isEmpty) {
          spgName = lastSpgName;
        } else {
          lastSpgName = spgName;
        }

        if (spgName.isEmpty) continue;
        if (spgName == 'TOTAL') continue;

        final qtySold = int.tryParse(qtyStr) ?? 0;

        if (qtySold > 0) {
          salesItems.add(SalesImportItem(
            spgName: spgName,
            productName: productName.trim().toUpperCase(),
            qtySold: qtySold,
          ));
        }

        // Extract cash (only once per unique SPG)
        if (!seenSpgNames.contains(spgName) && cashColIndex != -1 && nonCashColIndex != -1) {
          seenSpgNames.add(spgName);
          
          final cashStr = _getCellValueDouble(row[cashColIndex]);
          final nonCashStr = _getCellValueDouble(row[nonCashColIndex]);
          
          cashItems.add(CashImportItem(
            spgName: spgName,
            cashReceived: cashStr,
            qrisReceived: nonCashStr,
          ));
        }
      }
    }

    return TransactionImportResult(salesItems: salesItems, cashItems: cashItems);
  }

  static int _findColumnIndex(List<Data?> row, String headerName) {
    for (int i = 0; i < row.length; i++) {
      final cell = row[i];
      if (cell != null) {
        final value = _getCellValue(cell).toUpperCase().trim();
        if (value == headerName.toUpperCase()) {
          return i;
        }
      }
    }
    return -1;
  }

  static String _getCellValue(Data? cell) {
    if (cell == null) return '';
    final value = cell.value;
    if (value == null) return '';

    if (value is TextCellValue) {
      final textSpan = value.value;
      return textSpan.text ?? '';
    } else if (value is IntCellValue) {
      return value.value.toString();
    } else if (value is DoubleCellValue) {
      return value.value.toInt().toString();
    }

    return '';
  }

  static double _getCellValueDouble(Data? cell) {
    if (cell == null) return 0;
    final value = cell.value;
    if (value == null) return 0;

    if (value is IntCellValue) {
      return value.value.toDouble();
    } else if (value is DoubleCellValue) {
      return value.value;
    } else if (value is TextCellValue) {
      final textSpan = value.value;
      final text = textSpan.text ?? '';
      return double.tryParse(text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    }

    return 0;
  }

  static Future<TransactionImportResult> _parseCsv(PlatformFile platformFile) async {
    String fileString;
    if (kIsWeb) {
      fileString = utf8.decode(platformFile.bytes!);
    } else {
      fileString = await File(platformFile.path!).readAsString();
    }
    
    final lines = fileString.split(RegExp(r'\r\n|\r|\n'));
    final salesItems = <SalesImportItem>[];
    final cashItems = <CashImportItem>[];
    final seenSpgNames = <String>{};

    if (lines.length < 5) return TransactionImportResult(salesItems: [], cashItems: []);

    final headerRow = _splitCsvLine(lines[3]);
    final nameColIndex = _findCsvColumnIndex(headerRow, 'Name');
    final productColIndex = _findCsvColumnIndex(headerRow, 'Product');
    final qtyColIndex = _findCsvColumnIndex(headerRow, 'Qty');
    final cashColIndex = _findCsvColumnIndex(headerRow, 'Total Cash');
    final nonCashColIndex = _findCsvColumnIndex(headerRow, 'Total Non-Cash');

    if (nameColIndex == -1 || productColIndex == -1 || qtyColIndex == -1) {
      return TransactionImportResult(salesItems: [], cashItems: []);
    }

    String lastSpgName = '';

    for (int i = 4; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final row = _splitCsvLine(line);
      if (row.length <= nameColIndex || row.length <= productColIndex || row.length <= qtyColIndex) {
        continue;
      }

      final spgNameRaw = row[nameColIndex].trim().toUpperCase();
      final productName = row[productColIndex].trim().toUpperCase();
      final qtyStr = row[qtyColIndex].trim();

      if (productName.isEmpty) continue;

      String spgName = spgNameRaw;
      if (spgName.isEmpty) {
        spgName = lastSpgName;
      } else {
        lastSpgName = spgName;
      }

      if (spgName.isEmpty) continue;
      if (spgName == 'TOTAL') continue;

      final qtySold = int.tryParse(qtyStr) ?? 0;

      if (qtySold > 0) {
        salesItems.add(SalesImportItem(
          spgName: spgName,
          productName: productName,
          qtySold: qtySold,
        ));
      }

      // Extract cash (only once per unique SPG)
      if (!seenSpgNames.contains(spgName) && cashColIndex != -1 && nonCashColIndex != -1) {
        if (row.length > cashColIndex && row.length > nonCashColIndex) {
          seenSpgNames.add(spgName);
          
          final cashStr = row[cashColIndex].trim().replaceAll(RegExp(r'[^\d.]'), '');
          final nonCashStr = row[nonCashColIndex].trim().replaceAll(RegExp(r'[^\d.]'), '');
          
          cashItems.add(CashImportItem(
            spgName: spgName,
            cashReceived: double.tryParse(cashStr) ?? 0,
            qrisReceived: double.tryParse(nonCashStr) ?? 0,
          ));
        }
      }
    }

    return TransactionImportResult(salesItems: salesItems, cashItems: cashItems);
  }

  static int _findCsvColumnIndex(List<String> row, String headerName) {
    for (int i = 0; i < row.length; i++) {
      if (row[i].trim().toUpperCase().replaceAll('"', '') == headerName.toUpperCase()) {
        return i;
      }
    }
    return -1;
  }

  static List<String> _splitCsvLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        inQuotes = !inQuotes;
      } else if (line[i] == ',' && !inQuotes) {
        result.add(currentField.toString());
        currentField.clear();
      } else {
        currentField.write(line[i]);
      }
    }
    result.add(currentField.toString());
    return result;
  }
}