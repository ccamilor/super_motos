import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

class WebClientesRepository implements ClientesRepository {
  @override
  Future<List<Cliente>> loadAll() async {
    try {
      final response = await SupabaseService.instance.client
          .from('clientes')
          .select();
      final list = response as List<dynamic>;
      final domainList = list.map((e) => _clienteFromMap(e as Map<String, dynamic>)).toList();
      domainList.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      return domainList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Cliente> create(Cliente cliente) async {
    final map = _clienteToMap(cliente);
    await SupabaseService.instance.client.from('clientes').insert(map);
    return cliente;
  }

  @override
  Future<Cliente> update(Cliente cliente) async {
    final map = _clienteToMap(cliente);
    await SupabaseService.instance.client
        .from('clientes')
        .update(map)
        .eq('codigo', cliente.codigo);
    return cliente;
  }

  @override
  Future<void> delete(String codigo) async {
    await SupabaseService.instance.client
        .from('clientes')
        .delete()
        .eq('codigo', codigo);
  }

  Map<String, dynamic> _clienteToMap(Cliente c) {
    return {
      'codigo': c.codigo,
      'nombre': c.nombre,
      'identificador_fiscal': c.identificadorFiscal,
      'direccion': c.direccion,
      'latitud': c.latitud,
      'longitud': c.longitud,
      'limite_credito': c.limiteCredito,
      'saldo_pendiente': c.saldoPendiente,
      'estado_cuenta': c.estadoCuenta.name,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Cliente _clienteFromMap(Map<String, dynamic> m) {
    return Cliente(
      codigo: m['codigo'] as String,
      nombre: m['nombre'] as String,
      identificadorFiscal: (m['identificador_fiscal'] ?? '').toString(),
      direccion: (m['direccion'] ?? '').toString(),
      latitud: (m['latitud'] as num?)?.toDouble(),
      longitud: (m['longitud'] as num?)?.toDouble(),
      limiteCredito: (m['limite_credito'] as num?)?.toDouble() ?? 0.0,
      saldoPendiente: (m['saldo_pendiente'] as num?)?.toDouble() ?? 0.0,
      estadoCuenta: EstadoCuenta.values.firstWhere(
        (e) => e.name == m['estado_cuenta'],
        orElse: () => EstadoCuenta.activo,
      ),
    );
  }
}

ClientesRepository createClientesRepository() => WebClientesRepository();
