import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/inventario_camion.dart';

part 'inventario_camion_model.g.dart';

@collection
class InventarioCamionModel {
  Id id = Isar.autoIncrement;
  late int productoId;
  late int numeroCanasta;
  late int cantidad;
  bool isSynced = false;

  InventarioCamion toDomain() {
    return InventarioCamion(
      productoId: productoId,
      numeroCanasta: numeroCanasta,
      cantidad: cantidad,
      isSynced: isSynced,
    );
  }

  static InventarioCamionModel fromDomain(InventarioCamion domain) {
    return InventarioCamionModel()
      ..productoId = domain.productoId
      ..numeroCanasta = domain.numeroCanasta
      ..cantidad = domain.cantidad
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'numero_canasta': numeroCanasta,
      'cantidad': cantidad,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
