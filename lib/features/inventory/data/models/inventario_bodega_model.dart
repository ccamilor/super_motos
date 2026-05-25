import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/inventario_bodega.dart';

part 'inventario_bodega_model.g.dart';

@collection
class InventarioBodegaModel {
  Id id = Isar.autoIncrement;
  late int productoId;
  late int cantidad;

  InventarioBodega toDomain() {
    return InventarioBodega(
      productoId: productoId,
      cantidad: cantidad,
    );
  }

  static InventarioBodegaModel fromDomain(InventarioBodega domain) {
    return InventarioBodegaModel()
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad;
  }
}
