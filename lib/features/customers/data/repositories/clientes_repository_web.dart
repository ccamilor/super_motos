import 'dart:convert';

import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/services/clientes_seed_data.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _clientesStorageKey = 'super_motos_clientes_data';

class WebClientesRepository implements ClientesRepository {
  static List<Cliente> _clientes = [];
  static int _nextId = 0;

  @override
  Future<List<Cliente>> loadAll() async {
    if (_clientes.isEmpty) {
      final savedData = getWebStorage().getItem(_clientesStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _clientes = _decode(savedData);
        if (_clientes.isNotEmpty) {
          _nextId = _clientes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
      if (_clientes.isEmpty) {
        _clientes = List<Cliente>.from(ClientesSeedData.demoClientes);
        _nextId = _clientes.length + 1;
        getWebStorage().setItem(_clientesStorageKey, _encode(_clientes));
      }
    }

    final sorted = List<Cliente>.from(_clientes)
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return sorted;
  }

  @override
  Future<Cliente> create(Cliente cliente) async {
    final created = Cliente(
      id: _nextId++,
      nombre: cliente.nombre,
      identificadorFiscal: cliente.identificadorFiscal,
      direccion: cliente.direccion,
      latitud: cliente.latitud,
      longitud: cliente.longitud,
      limiteCredito: cliente.limiteCredito,
      saldoPendiente: cliente.saldoPendiente,
      estadoCuenta: cliente.estadoCuenta,
    );
    _clientes = [..._clientes, created];
    _persist();
    return created;
  }

  @override
  Future<Cliente> update(Cliente cliente) async {
    _clientes = _clientes
        .map((c) => c.id == cliente.id ? cliente : c)
        .toList();
    _persist();
    return cliente;
  }

  @override
  Future<void> delete(int id) async {
    _clientes = _clientes.where((c) => c.id != id).toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_clientesStorageKey, _encode(_clientes));
  }

  String _encode(List<Cliente> clientes) {
    return jsonEncode(clientes.map(_clienteToMap).toList());
  }

  List<Cliente> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _clienteFromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _clienteToMap(Cliente c) {
    return {
      'id': c.id,
      'nombre': c.nombre,
      'identificadorFiscal': c.identificadorFiscal,
      'direccion': c.direccion,
      'latitud': c.latitud,
      'longitud': c.longitud,
      'limiteCredito': c.limiteCredito,
      'saldoPendiente': c.saldoPendiente,
      'estadoCuenta': c.estadoCuenta.name,
    };
  }

  Cliente _clienteFromMap(Map<String, dynamic> m) {
    return Cliente(
      id: m['id'] as int,
      nombre: m['nombre'] as String,
      identificadorFiscal: m['identificadorFiscal'] as String,
      direccion: m['direccion'] as String,
      latitud: (m['latitud'] as num?)?.toDouble(),
      longitud: (m['longitud'] as num?)?.toDouble(),
      limiteCredito: (m['limiteCredito'] as num).toDouble(),
      saldoPendiente: (m['saldoPendiente'] as num).toDouble(),
      estadoCuenta: EstadoCuenta.values.firstWhere(
        (e) => e.name == m['estadoCuenta'],
        orElse: () => EstadoCuenta.activo,
      ),
    );
  }
}

ClientesRepository createClientesRepository() => WebClientesRepository();
