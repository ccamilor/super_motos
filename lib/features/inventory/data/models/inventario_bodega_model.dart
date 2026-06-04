import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/inventario_bodega.dart';

part 'inventario_bodega_model.g.dart';

@collection
class InventarioBodegaModel {
  Id id = Isar.autoIncrement;
  late int productoId;
  late int cantidad;
  bool isSynced = false;

  InventarioBodega toDomain() {
    return InventarioBodega(
      productoId: productoId,
      cantidad: cantidad,
      isSynced: isSynced,
    );
  }

  static InventarioBodegaModel fromDomain(InventarioBodega domain) {
    return InventarioBodegaModel()
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'cantidad': cantidad,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
