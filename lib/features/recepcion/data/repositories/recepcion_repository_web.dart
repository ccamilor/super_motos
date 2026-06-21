import 'dart:convert';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/data/services/recepcion_seed_data.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _recepcionStorageKey = 'super_motos_recepciones_data';

class WebRecepcionRepository implements RecepcionRepository {
  static List<Recepcion> _recepciones = [];

  @override
  Future<List<Recepcion>> loadAll() async {
    if (_recepciones.isEmpty) {
      final savedData = getWebStorage().getItem(_recepcionStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _recepciones = _decode(savedData);
      }
      if (_recepciones.isEmpty) {
        _recepciones = List<Recepcion>.from(RecepcionSeedData.demoRecepciones);
        getWebStorage().setItem(_recepcionStorageKey, _encode(_recepciones));
      }
    }
    final sorted = List<Recepcion>.from(_recepciones)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted;
  }

  @override
  Future<List<Recepcion>> loadByProveedor(String proveedorId) async {
    await loadAll();
    return _recepciones
        .where((r) => r.proveedorId == proveedorId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Future<Recepcion> create(Recepcion recepcion) async {
    _recepciones = [..._recepciones, recepcion];
    _persist();
    return recepcion;
  }

  @override
  Future<Recepcion?> getByCodigo(String codigo) async {
    await loadAll();
    try {
      return _recepciones.firstWhere((r) => r.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    _recepciones = _recepciones.where((r) => r.codigo != codigo).toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_recepcionStorageKey, _encode(_recepciones));
  }

  String _encode(List<Recepcion> list) {
    return jsonEncode(list.map(_toMap).toList());
  }

  List<Recepcion> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _toMap(Recepcion r) {
    return {
      'codigo': r.codigo,
      'proveedorId': r.proveedorId,
      'fecha': r.fecha.toIso8601String(),
      'nroRemito': r.nroRemito,
      'observaciones': r.observaciones,
      'isSynced': r.isSynced,
      'detalles': r.detalles.map((d) => {
        'productoId': d.productoId,
        'cantidad': d.cantidad,
        'precioUnitario': d.precioUnitario,
        'destino': d.destino,
        'cantidadCamion': d.cantidadCamion,
        'cantidadBodega': d.cantidadBodega,
      }).toList(),
    };
  }

  Recepcion _fromMap(Map<String, dynamic> m) {
    return Recepcion(
      codigo: m['codigo'] as String,
      proveedorId: m['proveedorId'] as String,
      fecha: DateTime.parse(m['fecha'] as String),
      nroRemito: m['nroRemito'] as String?,
      observaciones: m['observaciones'] as String?,
      isSynced: m['isSynced'] as bool? ?? false,
      detalles: (m['detalles'] as List<dynamic>).map((d) => _detalleFromMap(d as Map<String, dynamic>)).toList(),
    );
  }

  DetalleRecepcion _detalleFromMap(Map<String, dynamic> m) {
    return DetalleRecepcion(
      productoId: m['productoId'] as String,
      cantidad: m['cantidad'] as int,
      precioUnitario: (m['precioUnitario'] as num).toDouble(),
      destino: m['destino'] as String,
      cantidadCamion: (m['cantidadCamion'] as num?)?.toInt(),
      cantidadBodega: (m['cantidadBodega'] as num?)?.toInt(),
    );
  }
}

RecepcionRepository createRecepcionRepository() => WebRecepcionRepository();
