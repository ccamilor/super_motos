import 'dart:convert';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/services/proveedores_seed_data.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';
import 'package:super_motos/features/inventory/presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:super_motos/features/inventory/presentation/pages/web_storage_web.dart';

const String _proveedoresStorageKey = 'super_motos_proveedores_data';

class WebProveedoresRepository implements ProveedoresRepository {
  static List<Proveedor> _proveedores = [];

  @override
  Future<List<Proveedor>> loadAll() async {
    if (_proveedores.isEmpty) {
      final savedData = getWebStorage().getItem(_proveedoresStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        _proveedores = _decode(savedData);
      }
      if (_proveedores.isEmpty) {
        _proveedores = List<Proveedor>.from(ProveedoresSeedData.demoProveedores);
        getWebStorage().setItem(_proveedoresStorageKey, _encode(_proveedores));
      }
    }
    final sorted = List<Proveedor>.from(_proveedores)
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return sorted;
  }

  @override
  Future<Proveedor> create(Proveedor proveedor) async {
    _proveedores = [..._proveedores, proveedor];
    _persist();
    return proveedor;
  }

  @override
  Future<Proveedor> update(Proveedor proveedor) async {
    _proveedores = _proveedores
        .map((p) => p.codigo == proveedor.codigo ? proveedor : p)
        .toList();
    _persist();
    return proveedor;
  }

  @override
  Future<void> delete(String codigo) async {
    _proveedores = _proveedores.where((p) => p.codigo != codigo).toList();
    _persist();
  }

  void _persist() {
    getWebStorage().setItem(_proveedoresStorageKey, _encode(_proveedores));
  }

  String _encode(List<Proveedor> list) {
    return jsonEncode(list.map(_toMap).toList());
  }

  List<Proveedor> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _toMap(Proveedor p) {
    return {
      'codigo': p.codigo,
      'nombre': p.nombre,
      'nit': p.nit,
      'telefono': p.telefono,
      'direccion': p.direccion,
    };
  }

  Proveedor _fromMap(Map<String, dynamic> m) {
    return Proveedor(
      codigo: m['codigo'] as String,
      nombre: m['nombre'] as String,
      nit: m['nit'] as String,
      telefono: m['telefono'] as String,
      direccion: m['direccion'] as String,
    );
  }
}

ProveedoresRepository createProveedoresRepository() => WebProveedoresRepository();
