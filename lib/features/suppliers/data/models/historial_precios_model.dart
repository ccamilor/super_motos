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
  bool isSynced = false;

  HistorialPrecio toDomain() {
    return HistorialPrecio(
      id: id,
      productoId: productoId,
      proveedorId: proveedorId,
      precioCompra: precioCompra,
      fechaRegistro: fechaRegistro,
      isSynced: isSynced,
    );
  }

  static HistorialPreciosModel fromDomain(HistorialPrecio domain) {
    return HistorialPreciosModel()
      ..id = domain.id
      ..productoId = domain.productoId
      ..proveedorId = domain.proveedorId
      ..precioCompra = domain.precioCompra
      ..fechaRegistro = domain.fechaRegistro
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'proveedor_id': proveedorId,
      'precio_compra': precioCompra,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}