import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<bool> saveCsvContent(String content, String fileName) async {
  final bytes = Uint8List.fromList(utf8.encode(content));

  final path = await FilePicker.saveFile(
    dialogTitle: 'Exportar inventario',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['csv'],
    bytes: bytes,
  );

  if (path == null) return false;

  // En Android/iOS file_picker ya escribe el archivo con los bytes.
  // En escritorio (Windows/macOS/Linux) saveFile solo devuelve la ruta
  // elegida, por lo que debemos escribir nosotros.
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    final file = File(path);
    await file.writeAsString(content);
  }

  return true;
}
