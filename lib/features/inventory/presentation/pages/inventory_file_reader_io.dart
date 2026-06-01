import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<String> readPickedFileAsString(PlatformFile file) async {
  final path = file.path;
  if (path == null || path.isEmpty) {
    throw UnsupportedError('El archivo seleccionado no expone una ruta local.');
  }

  return File(path).readAsString();
}
