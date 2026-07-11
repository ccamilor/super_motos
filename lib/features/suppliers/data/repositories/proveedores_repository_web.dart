import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class WebProveedoresRepository implements ProveedoresRepository {
  @override
  Future<List<Proveedor>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('proveedores')
          .select();
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _proveedorFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Proveedor> create(Proveedor proveedor) async {
    final map = _proveedorToMap(proveedor);
    await SupabaseService.instance.client.from('proveedores').insert(map);
    return proveedor;
  }

  @override
  Future<Proveedor> update(Proveedor proveedor) async {
    final map = _proveedorToMap(proveedor);
    await SupabaseService.instance.client
        .from('proveedores')
        .update(map)
        .eq('codigo', proveedor.codigo);
    return proveedor;
  }

  @override
  Future<void> delete(String codigo) async {
    await SupabaseService.instance.client
        .from('proveedores')
        .delete()
        .eq('codigo', codigo);
  }

  Map<String, dynamic> _proveedorToMap(Proveedor p) {
    return {
      'codigo': p.codigo,
      'nombre': p.nombre,
      'nit': p.nit,
      'telefono': p.telefono,
      'direccion': p.direccion,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Proveedor _proveedorFromMap(Map<String, dynamic> m) {
    return Proveedor(
      codigo: m['codigo'] as String,
      nombre: m['nombre'] as String,
      nit: (m['nit'] ?? '').toString(),
      telefono: (m['telefono'] ?? '').toString(),
      direccion: (m['direccion'] ?? '').toString(),
    );
  }
}

ProveedoresRepository createProveedoresRepository() => WebProveedoresRepository();
