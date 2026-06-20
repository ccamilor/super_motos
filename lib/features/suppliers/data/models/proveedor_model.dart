import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

part 'proveedor_model.g.dart';

@collection
class ProveedorModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String nombre;
  late String nit;
  late String telefono;
  late String direccion;
  bool isSynced = false;

  Proveedor toDomain() {
    return Proveedor(
      codigo: codigo,
      nombre: nombre,
      nit: nit,
      telefono: telefono,
      direccion: direccion,
      isSynced: isSynced,
    );
  }

  static ProveedorModel fromDomain(Proveedor domain) {
    return ProveedorModel()
      ..codigo = domain.codigo
      ..nombre = domain.nombre
      ..nit = domain.nit
      ..telefono = domain.telefono
      ..direccion = domain.direccion
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'nit': nit,
      'telefono': telefono,
      'direccion': direccion,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
