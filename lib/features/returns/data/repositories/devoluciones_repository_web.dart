import 'dart:convert';

import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/services/devoluciones_seed_data.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

const String _devolucionesStorageKey = 'super_motos_devoluciones_data';

class WebDevolucionesRepository implements DevolucionesRepository {
  static List<Devolucion> _devoluciones = [];
  static int _nextId = 0;

  @override
  Future<List<Devolucion>> loadAll() async {
    if (_devoluciones.isEmpty) {
      final savedData = getWebStorage().getItem(_devolucionesStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _devoluciones = _decode(savedData);
        if (_devoluciones.isNotEmpty) {
          _nextId = _devoluciones.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
      if (_devoluciones.isEmpty) {
        _devoluciones = List<Devolucion>.from(DevolucionesSeedData.demoDevoluciones);
        _nextId = _devoluciones.length + 1;
        getWebStorage().setItem(_devolucionesStorageKey, _encode(_devoluciones));
      }
    }

    final sorted = List<Devolucion>.from(_devoluciones)
      ..sort((a, b) => b.fechaDevolucion.compareTo(a.fechaDevolucion));
    return sorted;
  }

  @override
  Future<Devolucion> create(Devolucion devolucion) async {
    final created = Devolucion(
      id: _nextId++,
      facturaId: devolucion.facturaId,
      productoId: devolucion.productoId,
      cantidad: devolucion.cantidad,
      numeroCanastaDestino: devolucion.numeroCanastaDestino,
      fechaDevolucion: devolucion.fechaDevolucion,
      motivo: devolucion.motivo,
      isSynced: devolucion.isSynced,
    );
    _devoluciones = [..._devoluciones, created];
    _persist();
    return created;
  }

  @override
  Future<Devolucion?> getById(int id) async {
    try {
      return _devoluciones.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(int id) async {
    _devoluciones = _devoluciones.where((d) => d.id != id).toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_devolucionesStorageKey, _encode(_devoluciones));
  }

  String _encode(List<Devolucion> devoluciones) {
    return jsonEncode(devoluciones.map(_devolucionToMap).toList());
  }

  List<Devolucion> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _devolucionFromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _devolucionToMap(Devolucion d) {
    return {
      'id': d.id,
      'facturaId': d.facturaId,
      'productoId': d.productoId,
      'cantidad': d.cantidad,
      'numeroCanastaDestino': d.numeroCanastaDestino,
      'fechaDevolucion': d.fechaDevolucion.toIso8601String(),
      'motivo': d.motivo,
      'isSynced': d.isSynced,
    };
  }

  Devolucion _devolucionFromMap(Map<String, dynamic> m) {
    return Devolucion(
      id: m['id'] as int,
      facturaId: m['facturaId'] as String,
      productoId: m['productoId'] as String,
      cantidad: m['cantidad'] as int,
      numeroCanastaDestino: m['numeroCanastaDestino'] as String,
      fechaDevolucion: DateTime.parse(m['fechaDevolucion'] as String),
      motivo: m['motivo'] as String,
      isSynced: m['isSynced'] as bool? ?? false,
    );
  }
}

DevolucionesRepository createDevolucionesRepository() => WebDevolucionesRepository();
