import 'dart:convert';

import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/services/devoluciones_seed_data.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

const String _devolucionesStorageKey = 'super_motos_devoluciones_data';

class WebDevolucionesRepository implements DevolucionesRepository {
  static List<Devolucion> _devoluciones = [];

  @override
  Future<List<Devolucion>> loadAll() async {
    if (_devoluciones.isEmpty) {
      final savedData = getWebStorage().getItem(_devolucionesStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _devoluciones = _decode(savedData);
      }
      if (_devoluciones.isEmpty) {
        _devoluciones = List<Devolucion>.from(DevolucionesSeedData.demoDevoluciones);
        getWebStorage().setItem(_devolucionesStorageKey, _encode(_devoluciones));
      }
    }

    final sorted = List<Devolucion>.from(_devoluciones)
      ..sort((a, b) => b.fechaDevolucion.compareTo(a.fechaDevolucion));
    return sorted;
  }

  @override
  Future<Devolucion> create(Devolucion devolucion) async {
    _devoluciones = [..._devoluciones, devolucion];
    _persist();
    return devolucion;
  }

  @override
  Future<Devolucion?> getByCodigo(String codigo) async {
    try {
      return _devoluciones.firstWhere((d) => d.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    _devoluciones = _devoluciones.where((d) => d.codigo != codigo).toList();
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
      'codigo': d.codigo,
      'facturaId': d.facturaId,
      'productoId': d.productoId,
      'cantidad': d.cantidad,
      'canastaDestino': d.canastaDestino,
      'fechaDevolucion': d.fechaDevolucion.toIso8601String(),
      'motivo': d.motivo,
      'isSynced': d.isSynced,
    };
  }

  Devolucion _devolucionFromMap(Map<String, dynamic> m) {
    return Devolucion(
      codigo: m['codigo'] as String,
      facturaId: m['facturaId'] as String,
      productoId: m['productoId'] as String,
      cantidad: m['cantidad'] as int,
      canastaDestino: m['canastaDestino'] as String,
      fechaDevolucion: DateTime.parse(m['fechaDevolucion'] as String),
      motivo: m['motivo'] as String,
      isSynced: m['isSynced'] as bool? ?? false,
    );
  }
}

DevolucionesRepository createDevolucionesRepository() => WebDevolucionesRepository();
