import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<bool> saveCsvContent(String content, String fileName) async {
  final path = await FilePicker.saveFile(
    dialogTitle: 'Exportar inventario',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (path == null) return false;

  final file = File(path);
  await file.writeAsString(content);
  return true;
}
