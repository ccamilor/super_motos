import 'dart:convert';
import 'package:web/web.dart' as web;

Future<bool> saveCsvContent(String content, String fileName) async {
  final encoded = Uri.encodeComponent(content);
  final dataUri = 'data:text/csv;charset=utf-8,$encoded';

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUri;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);

  return true;
}
