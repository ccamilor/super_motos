import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

part 'historial_precios_model.g.dart';

@collection
class HistorialPreciosModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String productoId;
  late String proveedorId;
  late double precioCompra;
  late DateTime fechaRegistro;
  bool isSynced = false;

  HistorialPrecio toDomain() {
    return HistorialPrecio(
      codigo: codigo,
      productoId: productoId,
      proveedorId: proveedorId,
      precioCompra: precioCompra,
      fechaRegistro: fechaRegistro,
      isSynced: isSynced,
    );
  }

  static HistorialPreciosModel fromDomain(HistorialPrecio domain) {
    return HistorialPreciosModel()
      ..codigo = domain.codigo
      ..productoId = domain.productoId
      ..proveedorId = domain.proveedorId
      ..precioCompra = domain.precioCompra
      ..fechaRegistro = domain.fechaRegistro
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'producto_id': productoId,
      'proveedor_id': proveedorId,
      'precio_compra': precioCompra,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
