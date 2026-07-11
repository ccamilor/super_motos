import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

class WebDevolucionesRepository implements DevolucionesRepository {
  @override
  Future<List<Devolucion>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('devoluciones')
          .select();
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _devolucionFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => b.fechaDevolucion.compareTo(a.fechaDevolucion));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Devolucion> create(Devolucion devolucion) async {
    final map = _devolucionToMap(devolucion);
    await SupabaseService.instance.client.from('devoluciones').insert(map);
    return devolucion;
  }

  @override
  Future<Devolucion?> getByCodigo(String codigo) async {
    try {
      final response = await SupabaseService.instance.client
          .from('devoluciones')
          .select()
          .eq('codigo', codigo)
          .maybeSingle();
      if (response == null) return null;
      return _devolucionFromMap(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String codigo) async {
    await SupabaseService.instance.client
        .from('devoluciones')
        .delete()
        .eq('codigo', codigo);
  }

  Map<String, dynamic> _devolucionToMap(Devolucion d) {
    return {
      'codigo': d.codigo,
      'factura_id': d.facturaId,
      'producto_id': d.productoId,
      'cantidad': d.cantidad,
      'canasta_destino': d.canastaDestino,
      'fecha_devolucion': d.fechaDevolucion.toIso8601String(),
      'motivo': d.motivo,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Devolucion _devolucionFromMap(Map<String, dynamic> m) {
    return Devolucion(
      codigo: m['codigo'] as String,
      facturaId: (m['factura_id'] ?? '').toString(),
      productoId: (m['producto_id'] ?? '').toString(),
      cantidad: m['cantidad'] as int? ?? 0,
      canastaDestino: (m['canasta_destino'] ?? '').toString(),
      fechaDevolucion: DateTime.parse(m['fecha_devolucion'] as String),
      motivo: (m['motivo'] ?? '').toString(),
      isSynced: m['is_synced'] as bool? ?? true,
    );
  }
}

DevolucionesRepository createDevolucionesRepository() => WebDevolucionesRepository();
