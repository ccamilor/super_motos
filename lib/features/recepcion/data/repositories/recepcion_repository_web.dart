import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';

class WebRecepcionRepository implements RecepcionRepository {
  @override
  Future<List<Recepcion>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('recepciones')
          .select('*, detalles_recepcion(*)');
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _recepcionFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => b.fecha.compareTo(a.fecha));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Recepcion>> loadByProveedor(String proveedorId) async {
    try {
      final response = await SupabaseService.instance.client
          .from('recepciones')
          .select('*, detalles_recepcion(*)')
          .eq('proveedor_id', proveedorId);
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _recepcionFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => b.fecha.compareTo(a.fecha));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Recepcion> create(Recepcion recepcion) async {
    final client = SupabaseService.instance.client;
    await client.from('recepciones').insert(_recepcionToMap(recepcion));
    if (recepcion.detalles.isNotEmpty) {
      final detailsJson = recepcion.detalles.asMap().entries.map((entry) {
        final idx = entry.key;
        final d = entry.value;
        return {
          'codigo': '${recepcion.codigo}_$idx',
          'recepcion_codigo': recepcion.codigo,
          'producto_id': d.productoId,
          'cantidad': d.cantidad,
          'precio_unitario': d.precioUnitario,
          'destino': d.destino,
          'cantidad_camion': d.cantidadCamion,
          'cantidad_bodega': d.cantidadBodega,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      await client.from('detalles_recepcion').insert(detailsJson);
    }
    return recepcion;
  }

  @override
  Future<Recepcion?> getByCodigo(String codigo) async {
    try {
      final response = await SupabaseService.instance.client
          .from('recepciones')
          .select('*, detalles_recepcion(*)')
          .eq('codigo', codigo)
          .maybeSingle();
      if (response == null) return null;
      return _recepcionFromMap(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    final client = SupabaseService.instance.client;
    await client.from('detalles_recepcion').delete().eq('recepcion_codigo', codigo);
    await client.from('recepciones').delete().eq('codigo', codigo);
  }

  Map<String, dynamic> _recepcionToMap(Recepcion r) {
    return {
      'codigo': r.codigo,
      'proveedor_id': r.proveedorId,
      'fecha': r.fecha.toIso8601String(),
      'nro_remito': r.nroRemito,
      'observaciones': r.observaciones,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Recepcion _recepcionFromMap(Map<String, dynamic> m) {
    final detallesRaw = m['detalles_recepcion'] as List<dynamic>? ?? [];
    return Recepcion(
      codigo: m['codigo'] as String,
      proveedorId: (m['proveedor_id'] ?? '').toString(),
      fecha: DateTime.parse(m['fecha'] as String),
      nroRemito: m['nro_remito']?.toString(),
      observaciones: m['observaciones']?.toString(),
      isSynced: m['is_synced'] as bool? ?? true,
      detalles: detallesRaw.map((d) => _detalleFromMap(d as Map<String, dynamic>)).toList(),
    );
  }

  DetalleRecepcion _detalleFromMap(Map<String, dynamic> m) {
    return DetalleRecepcion(
      productoId: (m['producto_id'] ?? '').toString(),
      cantidad: m['cantidad'] as int? ?? 0,
      precioUnitario: (m['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      destino: (m['destino'] ?? 'camion').toString(),
      cantidadCamion: (m['cantidad_camion'] as num?)?.toInt(),
      cantidadBodega: (m['cantidad_bodega'] as num?)?.toInt(),
    );
  }
}

RecepcionRepository createRecepcionRepository() => WebRecepcionRepository();
