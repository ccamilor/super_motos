import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';

InventoryRepository createInventoryRepository() {
  throw UnsupportedError('No hay repositorio de inventario disponible para esta plataforma.');
}

class UnsupportedInventoryRepository implements InventoryRepository {
  @override
  Future<InventorySnapshot> importCsv(String csvContent) {
    throw UnsupportedError('No hay repositorio de inventario disponible para esta plataforma.');
  }

  @override
  Future<InventorySnapshot> loadInventory() {
    throw UnsupportedError('No hay repositorio de inventario disponible para esta plataforma.');
  }
}
