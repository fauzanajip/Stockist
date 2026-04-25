import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(List<int> bytes, String fileName, {String? mimeType}) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes);

  final xFile = XFile(filePath);
  await Share.shareXFiles([xFile], text: 'Backup Data Stockist App');
}
