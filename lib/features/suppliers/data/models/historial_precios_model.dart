import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

part 'historial_precios_model.g.dart';

@collection
class HistorialPreciosModel {
  Id id = Isar.autoIncrement;
  late String productoId;
  late String proveedorId;
  late double precioCompra;
  late DateTime fechaRegistro;

  HistorialPrecio toDomain() {
    return HistorialPrecio(
      id: id,
      productoId: productoId,
      proveedorId: proveedorId,
      precioCompra: precioCompra,
      fechaRegistro: fechaRegistro,
    );
  }

  static HistorialPreciosModel fromDomain(HistorialPrecio domain) {
    return HistorialPreciosModel()
      ..id = domain.id
      ..productoId = domain.productoId
      ..proveedorId = domain.proveedorId
      ..precioCompra = domain.precioCompra
      ..fechaRegistro = domain.fechaRegistro;
  }
}