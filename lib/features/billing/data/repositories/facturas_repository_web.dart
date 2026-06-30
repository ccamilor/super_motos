import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/services/facturas_seed_data.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _facturasStorageKey = 'super_motos_facturas_data';

class WebFacturasRepository implements FacturasRepository {
  static List<Factura> _facturas = [];
  static bool _loaded = false;

  @override
  Future<List<Factura>> loadAll() async {
    if (!_loaded) {
      _loaded = true;
      final savedData = getWebStorage().getItem(_facturasStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _facturas = _decode(savedData);
      }
      if (_facturas.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final alreadySeeded = prefs.getBool('super_motos_facturas_seeded') ?? false;
        if (!alreadySeeded) {
          _facturas = List<Factura>.from(FacturasSeedData.demoFacturas);
          await prefs.setBool('super_motos_facturas_seeded', true);
          getWebStorage().setItem(_facturasStorageKey, _encode(_facturas));
        }
      }
    }

    final sorted = List<Factura>.from(_facturas)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted;
  }

  @override
  Future<Factura> create(Factura factura) async {
    _facturas = [..._facturas, factura];
    _persist();
    return factura;
  }

  @override
  Future<Factura> update(Factura factura) async {
    final updated = factura.copyWith(isSynced: false);
    _facturas = _facturas.map((f) => f.codigo == factura.codigo ? updated : f).toList();
    _persist();
    return updated;
  }

  @override
  Future<Factura?> getByCodigo(String codigo) async {
    try {
      return _facturas.firstWhere((f) => f.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    _facturas = _facturas.where((f) => f.codigo != codigo).toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_facturasStorageKey, _encode(_facturas));
  }

  String _encode(List<Factura> facturas) {
    return jsonEncode(facturas.map(_facturaToMap).toList());
  }

  List<Factura> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _facturaFromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _facturaToMap(Factura f) {
    return {
      'codigo': f.codigo,
      'clienteId': f.clienteId,
      'vendedorId': f.vendedorId,
      'fecha': f.fecha.toIso8601String(),
      'total': f.total,
      'tipoPago': f.tipoPago.name,
      'latitudVenta': f.latitudVenta,
      'longitudVenta': f.longitudVenta,
      'detalles': f.detalles.map(_detalleToMap).toList(),
      'isSynced': f.isSynced,
    };
  }

  Map<String, dynamic> _detalleToMap(DetalleFactura d) {
    return {
      'productoId': d.productoId,
      'cantidad': d.cantidad,
      'precioUnitario': d.precioUnitario,
      'subtotal': d.subtotal,
    };
  }

  Factura _facturaFromMap(Map<String, dynamic> m) {
    return Factura(
      codigo: m['codigo'] as String,
      clienteId: m['clienteId'] as String,
      vendedorId: m['vendedorId'] as String,
      fecha: DateTime.parse(m['fecha'] as String),
      total: (m['total'] as num).toDouble(),
      tipoPago: TipoPago.values.firstWhere(
        (e) => e.name == m['tipoPago'],
        orElse: () => TipoPago.contado,
      ),
      latitudVenta: (m['latitudVenta'] as num?)?.toDouble(),
      longitudVenta: (m['longitudVenta'] as num?)?.toDouble(),
      detalles: (m['detalles'] as List<dynamic>)
          .map((d) => _detalleFromMap(d as Map<String, dynamic>))
          .toList(),
      isSynced: m['isSynced'] as bool? ?? false,
    );
  }

  DetalleFactura _detalleFromMap(Map<String, dynamic> m) {
    return DetalleFactura(
      productoId: m['productoId'] as String,
      cantidad: m['cantidad'] as int,
      precioUnitario: (m['precioUnitario'] as num).toDouble(),
      subtotal: (m['subtotal'] as num).toDouble(),
    );
  }
}

FacturasRepository createFacturasRepository() => WebFacturasRepository();
