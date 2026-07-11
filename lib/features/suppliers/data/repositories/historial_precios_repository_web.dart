import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

class WebHistorialPreciosRepository implements HistorialPreciosRepository {
  @override
  Future<List<HistorialPrecio>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('historial_precios')
          .select();
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _historialFromMap(e as Map<String, dynamic>)).toList();
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<HistorialPrecio>> loadByProveedorId(String proveedorId) async {
    try {
      final response = await SupabaseService.instance.client
          .from('historial_precios')
          .select()
          .eq('proveedor_id', proveedorId);
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _historialFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<HistorialPrecio> create(HistorialPrecio historial) async {
    final map = _historialToMap(historial);
    await SupabaseService.instance.client.from('historial_precios').insert(map);
    return historial;
  }

  @override
  Future<void> delete(String codigo) async {
    await SupabaseService.instance.client
        .from('historial_precios')
        .delete()
        .eq('codigo', codigo);
  }

  @override
  Future<void> deleteByProveedorId(String proveedorId) async {
    await SupabaseService.instance.client
        .from('historial_precios')
        .delete()
        .eq('proveedor_id', proveedorId);
  }

  @override
  Future<HistorialPrecio> upsertPrecio({
    required String proveedorId,
    required String productoId,
    required double precioCompra,
  }) async {
    final client = SupabaseService.instance.client;
    final existing = await client
        .from('historial_precios')
        .select()
        .eq('proveedor_id', proveedorId)
        .eq('producto_id', productoId)
        .maybeSingle();

    final HistorialPrecio hp;
    if (existing != null) {
      hp = HistorialPrecio(
        codigo: existing['codigo'] as String,
        proveedorId: proveedorId,
        productoId: productoId,
        precioCompra: precioCompra,
        fechaRegistro: DateTime.now(),
      );
      await client
          .from('historial_precios')
          .update(_historialToMap(hp))
          .eq('codigo', hp.codigo);
    } else {
      hp = HistorialPrecio(
        codigo: 'HP-${DateTime.now().millisecondsSinceEpoch}',
        proveedorId: proveedorId,
        productoId: productoId,
        precioCompra: precioCompra,
        fechaRegistro: DateTime.now(),
      );
      await client.from('historial_precios').insert(_historialToMap(hp));
    }
    return hp;
  }

  Map<String, dynamic> _historialToMap(HistorialPrecio h) {
    return {
      'codigo': h.codigo,
      'producto_id': h.productoId,
      'proveedor_id': h.proveedorId,
      'precio_compra': h.precioCompra,
      'fecha_registro': h.fechaRegistro.toIso8601String(),
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  HistorialPrecio _historialFromMap(Map<String, dynamic> m) {
    return HistorialPrecio(
      codigo: m['codigo'] as String,
      productoId: (m['producto_id'] ?? '').toString(),
      proveedorId: (m['proveedor_id'] ?? '').toString(),
      precioCompra: (m['precio_compra'] as num?)?.toDouble() ?? 0.0,
      fechaRegistro: DateTime.parse(m['fecha_registro'] as String),
    );
  }
}

HistorialPreciosRepository createHistorialPreciosRepository() =>
    WebHistorialPreciosRepository();
