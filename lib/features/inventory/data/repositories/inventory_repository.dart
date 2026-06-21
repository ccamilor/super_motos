import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

abstract class InventoryRepository {
  Future<InventorySnapshot> loadInventory();
  Future<InventorySnapshot> importCsv(String csvContent);
  Future<void> decrementCamionStock(String productoId, int cantidad);
  Future<void> incrementCamionStock(String productoId, int cantidad);
  Future<void> incrementBodegaStock(String productoId, int cantidad);
  Future<void> createProductFromRecepcion(String productoId, int cantCamion, int cantBodega);
  Future<InventorySnapshot> createProduct(InventoryEntry entry);
  Future<InventorySnapshot> updateProduct(InventoryEntry entry);
  Future<InventorySnapshot> deleteProduct(String codigo);
}
