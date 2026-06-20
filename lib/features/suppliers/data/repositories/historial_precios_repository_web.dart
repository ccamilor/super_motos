import 'dart:convert';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _historialStorageKey = 'super_motos_historial_precios_data';

class WebHistorialPreciosRepository implements HistorialPreciosRepository {
  static List<HistorialPrecio> _historial = [];

  @override
  Future<List<HistorialPrecio>> loadAll() async {
    if (_historial.isEmpty) {
      final savedData = getWebStorage().getItem(_historialStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _historial = _decode(savedData);
      }
    }
    return List.from(_historial);
  }

  @override
  Future<List<HistorialPrecio>> loadByProveedorId(String proveedorId) async {
    await loadAll();
    return _historial
        .where((h) => h.proveedorId == proveedorId)
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  @override
  Future<HistorialPrecio> create(HistorialPrecio historial) async {
    await loadAll();
    _historial = [..._historial, historial];
    _persist();
    return historial;
  }

  @override
  Future<void> delete(String codigo) async {
    await loadAll();
    _historial = _historial.where((h) => h.codigo != codigo).toList();
    _persist();
  }

  @override
  Future<void> deleteByProveedorId(String proveedorId) async {
    await loadAll();
    _historial = _historial
        .where((h) => h.proveedorId != proveedorId)
        .toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_historialStorageKey, _encode(_historial));
  }

  String _encode(List<HistorialPrecio> list) {
    return jsonEncode(list.map(_toMap).toList());
  }

  List<HistorialPrecio> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _toMap(HistorialPrecio h) {
    return {
      'codigo': h.codigo,
      'productoId': h.productoId,
      'proveedorId': h.proveedorId,
      'precioCompra': h.precioCompra,
      'fechaRegistro': h.fechaRegistro.toIso8601String(),
    };
  }

  HistorialPrecio _fromMap(Map<String, dynamic> m) {
    return HistorialPrecio(
      codigo: m['codigo'] as String,
      productoId: m['productoId'] as String,
      proveedorId: m['proveedorId'] as String,
      precioCompra: (m['precioCompra'] as num).toDouble(),
      fechaRegistro: DateTime.parse(m['fechaRegistro'] as String),
    );
  }
}

HistorialPreciosRepository createHistorialPreciosRepository() =>
    WebHistorialPreciosRepository();
