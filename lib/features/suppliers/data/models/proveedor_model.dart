import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

part 'proveedor_model.g.dart';

@collection
class ProveedorModel {
  Id id = Isar.autoIncrement;
  late String nombre;
  late String nit;
  late String telefono;
  late String direccion;

  Proveedor toDomain() {
    return Proveedor(
      id: id,
      nombre: nombre,
      nit: nit,
      telefono: telefono,
      direccion: direccion,
    );
  }

  static ProveedorModel fromDomain(Proveedor domain) {
    return ProveedorModel()
      ..id = domain.id
      ..nombre = domain.nombre
      ..nit = domain.nit
      ..telefono = domain.telefono
      ..direccion = domain.direccion;
  }
}
