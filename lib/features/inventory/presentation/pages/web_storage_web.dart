import 'package:web/web.dart' as web;
import 'web_storage_stub.dart';

class WebStorageWeb implements WebStorage {
  @override
  String? getItem(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void setItem(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {}
  }
}

WebStorage getWebStorage() {
  return WebStorageWeb();
}
