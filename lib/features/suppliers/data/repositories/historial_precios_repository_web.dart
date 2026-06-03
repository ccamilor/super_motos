import 'dart:convert';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _historialStorageKey = 'super_motos_historial_precios_data';

class WebHistorialPreciosRepository implements HistorialPreciosRepository {
  static List<HistorialPrecio> _historial = [];
  static int _nextId = 0;

  @override
  Future<List<HistorialPrecio>> loadAll() async {
    if (_historial.isEmpty) {
      final savedData = getWebStorage().getItem(_historialStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _historial = _decode(savedData);
        if (_historial.isNotEmpty) {
          _nextId = _historial.map((h) => h.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
    }
    return List.from(_historial);
  }

  @override
  Future<List<HistorialPrecio>> loadByProveedorId(int proveedorId) async {
    await loadAll();
    return _historial
        .where((h) => h.proveedorId == proveedorId.toString())
        .toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  @override
  Future<HistorialPrecio> create(HistorialPrecio historial) async {
    await loadAll();
    final created = historial.copyWith(id: _nextId++);
    _historial = [..._historial, created];
    _persist();
    return created;
  }

  @override
  Future<void> delete(int id) async {
    await loadAll();
    _historial = _historial.where((h) => h.id != id).toList();
    _persist();
  }

  @override
  Future<void> deleteByProveedorId(int proveedorId) async {
    await loadAll();
    _historial = _historial
        .where((h) => h.proveedorId != proveedorId.toString())
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
      'id': h.id,
      'productoId': h.productoId,
      'proveedorId': h.proveedorId,
      'precioCompra': h.precioCompra,
      'fechaRegistro': h.fechaRegistro.toIso8601String(),
    };
  }

  HistorialPrecio _fromMap(Map<String, dynamic> m) {
    return HistorialPrecio(
      id: m['id'] as int,
      productoId: m['productoId'] as String,
      proveedorId: m['proveedorId'] as String,
      precioCompra: (m['precioCompra'] as num).toDouble(),
      fechaRegistro: DateTime.parse(m['fechaRegistro'] as String),
    );
  }
}

HistorialPreciosRepository createHistorialPreciosRepository() =>
    WebHistorialPreciosRepository();