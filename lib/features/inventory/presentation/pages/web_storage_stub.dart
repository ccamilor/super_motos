// Clase abstracta o interface para localStorage
abstract class WebStorage {
  static WebStorage get instance => throw UnsupportedError('No se puede inicializar WebStorage');
  String? getItem(String key);
  void setItem(String key, String value);
}

// Método global auxiliar para facilitar el uso
WebStorage getWebStorage() {
  throw UnsupportedError('No se puede llamar a getWebStorage en plataformas que no sean Web');
}
