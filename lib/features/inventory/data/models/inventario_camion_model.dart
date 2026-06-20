import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/inventario_camion.dart';

part 'inventario_camion_model.g.dart';

@collection
class InventarioCamionModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String productoId;
  late String canastaId;
  late int cantidad;
  bool isSynced = false;

  InventarioCamion toDomain() {
    return InventarioCamion(
      productoId: productoId,
      canastaId: canastaId,
      cantidad: cantidad,
      isSynced: isSynced,
    );
  }

  static InventarioCamionModel fromDomain(InventarioCamion domain) {
    return InventarioCamionModel()
      ..productoId = domain.productoId
      ..canastaId = domain.canastaId
      ..cantidad = domain.cantidad
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'producto_id': productoId,
      'canasta_id': canastaId,
      'cantidad': cantidad,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
