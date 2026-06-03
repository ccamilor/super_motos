import 'dart:convert';

import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/services/facturas_seed_data.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _facturasStorageKey = 'super_motos_facturas_data';

class WebFacturasRepository implements FacturasRepository {
  static List<Factura> _facturas = [];
  static int _nextId = 0;

  @override
  Future<List<Factura>> loadAll() async {
    if (_facturas.isEmpty) {
      final savedData = getWebStorage().getItem(_facturasStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _facturas = _decode(savedData);
        if (_facturas.isNotEmpty) {
          _nextId = _facturas.map((f) => f.numeroFactura).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
      if (_facturas.isEmpty) {
        _facturas = List<Factura>.from(FacturasSeedData.demoFacturas);
        _nextId = _facturas.length + 1;
        getWebStorage().setItem(_facturasStorageKey, _encode(_facturas));
      }
    }

    final sorted = List<Factura>.from(_facturas)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted;
  }

  @override
  Future<Factura> create(Factura factura) async {
    final created = Factura(
      numeroFactura: _nextId++,
      clienteId: factura.clienteId,
      vendedorId: factura.vendedorId,
      fecha: factura.fecha,
      total: factura.total,
      tipoPago: factura.tipoPago,
      latitudVenta: factura.latitudVenta,
      longitudVenta: factura.longitudVenta,
      detalles: factura.detalles,
      isSynced: factura.isSynced,
    );
    _facturas = [..._facturas, created];
    _persist();
    return created;
  }

  @override
  Future<Factura?> getById(int numeroFactura) async {
    try {
      return _facturas.firstWhere((f) => f.numeroFactura == numeroFactura);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(int numeroFactura) async {
    _facturas = _facturas.where((f) => f.numeroFactura != numeroFactura).toList();
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
      'numeroFactura': f.numeroFactura,
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
      numeroFactura: m['numeroFactura'] as int,
      clienteId: m['clienteId'] as int,
      vendedorId: m['vendedorId'] as int,
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
      productoId: m['productoId'] as int,
      cantidad: m['cantidad'] as int,
      precioUnitario: (m['precioUnitario'] as num).toDouble(),
      subtotal: (m['subtotal'] as num).toDouble(),
    );
  }
}

FacturasRepository createFacturasRepository() => WebFacturasRepository();
