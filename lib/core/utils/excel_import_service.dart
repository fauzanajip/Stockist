import 'dart:io';
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

class ExcelImportService {
  ExcelImportService._();

  static Future<FilePickerResult?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    return result;
  }

  static Future<List<SalesImportItem>> parseTransactionReport(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final items = <SalesImportItem>[];

    for (final sheetName in excel.tables.keys) {
      final sheet = excel[sheetName];
      if (sheet == null) continue;

      final rows = sheet.rows;

      if (rows.length < 5) continue;

      final headerRow = rows[3];
      final nameColIndex = _findColumnIndex(headerRow, 'Name');
      final productColIndex = _findColumnIndex(headerRow, 'Product');
      final qtyColIndex = _findColumnIndex(headerRow, 'Qty');

      if (nameColIndex == -1 || productColIndex == -1 || qtyColIndex == -1) {
        continue;
      }

      for (int i = 4; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final spgName = _getCellValue(row[nameColIndex]);
        final productName = _getCellValue(row[productColIndex]);
        final qtyStr = _getCellValue(row[qtyColIndex]);

        if (spgName.isEmpty || productName.isEmpty) continue;
        if (spgName.toUpperCase() == 'TOTAL') continue;

        final qtySold = int.tryParse(qtyStr) ?? 0;

        if (qtySold > 0) {
          items.add(SalesImportItem(
            spgName: spgName.trim().toUpperCase(),
            productName: productName.trim().toUpperCase(),
            qtySold: qtySold,
          ));
        }
      }
    }

    return items;
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
}