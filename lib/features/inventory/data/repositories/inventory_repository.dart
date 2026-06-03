import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';

abstract class InventoryRepository {
  Future<InventorySnapshot> loadInventory();
  Future<InventorySnapshot> importCsv(String csvContent);
  Future<void> decrementCamionStock(int productoId, int cantidad);
}
