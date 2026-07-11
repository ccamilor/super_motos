import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';

class WebFacturasRepository implements FacturasRepository {
  @override
  Future<List<Factura>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('facturas')
          .select('*, detalles_factura(*)');
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _facturaFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => b.fecha.compareTo(a.fecha));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Factura> create(Factura factura) async {
    final client = SupabaseService.instance.client;
    await client.from('facturas').insert(_facturaToMap(factura));
    if (factura.detalles.isNotEmpty) {
      final detailsJson = factura.detalles.asMap().entries.map((entry) {
        final idx = entry.key;
        final d = entry.value;
        return {
          'codigo': '${factura.codigo}_$idx',
          'factura_codigo': factura.codigo,
          'producto_id': d.productoId,
          'cantidad': d.cantidad,
          'precio_unitario': d.precioUnitario,
          'subtotal': d.subtotal,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      await client.from('detalles_factura').insert(detailsJson);
    }
    return factura;
  }

  @override
  Future<Factura> update(Factura factura) async {
    final client = SupabaseService.instance.client;
    await client
        .from('facturas')
        .update(_facturaToMap(factura))
        .eq('codigo', factura.codigo);
    await client
        .from('detalles_factura')
        .delete()
        .eq('factura_codigo', factura.codigo);
    if (factura.detalles.isNotEmpty) {
      final detailsJson = factura.detalles.asMap().entries.map((entry) {
        final idx = entry.key;
        final d = entry.value;
        return {
          'codigo': '${factura.codigo}_$idx',
          'factura_codigo': factura.codigo,
          'producto_id': d.productoId,
          'cantidad': d.cantidad,
          'precio_unitario': d.precioUnitario,
          'subtotal': d.subtotal,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      await client.from('detalles_factura').insert(detailsJson);
    }
    return factura;
  }

  @override
  Future<Factura?> getByCodigo(String codigo) async {
    try {
      final response = await SupabaseService.instance.client
          .from('facturas')
          .select('*, detalles_factura(*)')
          .eq('codigo', codigo)
          .maybeSingle();
      if (response == null) return null;
      return _facturaFromMap(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    final client = SupabaseService.instance.client;
    await client.from('detalles_factura').delete().eq('factura_codigo', codigo);
    await client.from('facturas').delete().eq('codigo', codigo);
  }

  Map<String, dynamic> _facturaToMap(Factura f) {
    return {
      'codigo': f.codigo,
      'cliente_id': f.clienteId,
      'vendedor_id': f.vendedorId,
      'fecha': f.fecha.toIso8601String(),
      'total': f.total,
      'tipo_pago': f.tipoPago.name,
      'latitud_venta': f.latitudVenta,
      'longitud_venta': f.longitudVenta,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Factura _facturaFromMap(Map<String, dynamic> m) {
    final detallesRaw = m['detalles_factura'] as List<dynamic>? ?? [];
    return Factura(
      codigo: m['codigo'] as String,
      clienteId: (m['cliente_id'] ?? '').toString(),
      vendedorId: (m['vendedor_id'] ?? '').toString(),
      fecha: DateTime.parse(m['fecha'] as String),
      total: (m['total'] as num?)?.toDouble() ?? 0.0,
      tipoPago: TipoPago.values.firstWhere(
        (e) => e.name == m['tipo_pago'],
        orElse: () => TipoPago.contado,
      ),
      latitudVenta: (m['latitud_venta'] as num?)?.toDouble(),
      longitudVenta: (m['longitud_venta'] as num?)?.toDouble(),
      detalles: detallesRaw.map((d) => _detalleFromMap(d as Map<String, dynamic>)).toList(),
      isSynced: m['is_synced'] as bool? ?? true,
    );
  }

  DetalleFactura _detalleFromMap(Map<String, dynamic> m) {
    return DetalleFactura(
      productoId: (m['producto_id'] ?? '').toString(),
      cantidad: m['cantidad'] as int? ?? 0,
      precioUnitario: (m['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

FacturasRepository createFacturasRepository() => WebFacturasRepository();
