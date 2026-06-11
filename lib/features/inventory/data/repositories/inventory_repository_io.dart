import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/stock_alert_service.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_seed_data.dart';

class IsarInventoryRepository implements InventoryRepository {
  Isar? get _isar => Isar.getInstance();
  final InventoryCsvParser _parser = const InventoryCsvParser();

  @override
  Future<InventorySnapshot> loadInventory() async {
    final isar = _isar;
    if (isar == null) {
      return InventorySnapshot.empty;
    }

    var productos = await isar.productoModels.where().findAll();
    if (productos.isEmpty) {
      await _seedDemoData(isar);
      productos = await isar.productoModels.where().findAll();
    }

    final camion = await isar.inventarioCamionModels.where().findAll();
    final bodega = await isar.inventarioBodegaModels.where().findAll();

    return InventorySnapshot(
      productos: productos,
      camion: camion,
      bodega: bodega,
    );
  }

  @override
  Future<InventorySnapshot> importCsv(String csvContent) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no está inicializado.');
    }

    final entries = _parser.parse(csvContent);
    if (entries.isEmpty) {
      throw FormatException('El CSV está vacío o no contiene filas válidas.');
    }

    await isar.writeTxn(() async {
      for (final entry in entries) {
        await isar.productoModels.put(entry.toProductoModel());
        await isar.inventarioCamionModels.put(entry.toCamionModel());
        await isar.inventarioBodegaModels.put(entry.toBodegaModel());
      }
    });

    for (final entry in entries) {
      SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(entry.toProductoModel().toJson()));
      SyncService.instance.enqueue('inventario_camion', SyncOperation.insert, jsonEncode(entry.toCamionModel().toJson()));
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.insert, jsonEncode(entry.toBodegaModel().toJson()));
    }

    return loadInventory();
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final entry in InventorySeedData.demoEntries) {
        await isar.productoModels.put(entry.toProductoModel());
        await isar.inventarioCamionModels.put(entry.toCamionModel());
        await isar.inventarioBodegaModels.put(entry.toBodegaModel());
      }
    });
  }

  @override
  Future<void> decrementCamionStock(int productoId, int cantidad) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    await isar.writeTxn(() async {
      final model = await isar.inventarioCamionModels
          .filter()
          .productoIdEqualTo(productoId)
          .findFirst();
      if (model == null) {
        throw StateError('No hay registro de stock en el camion para producto $productoId');
      }
      if (model.cantidad < cantidad) {
        throw StateError(
          'Stock insuficiente en el camion para producto $productoId (disponible: ${model.cantidad}, requerido: $cantidad)',
        );
      }
      model.cantidad -= cantidad;
      await isar.inventarioCamionModels.put(model);

      final producto = await isar.productoModels.get(productoId);
      if (producto != null) {
        await StockAlertService.instance.checkAndNotify(
          productoId: productoId,
          productoNombre: producto.nombre,
          nuevaCantidad: model.cantidad,
          stockMinimo: producto.stockMinimo,
        );
      }
    });

    final updated = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo(productoId)
        .findFirst();
    if (updated != null) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.update, jsonEncode(updated.toJson()));
    }
  }

  @override
  Future<void> incrementCamionStock(int productoId, int cantidad) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    await isar.writeTxn(() async {
      final model = await isar.inventarioCamionModels
          .filter()
          .productoIdEqualTo(productoId)
          .findFirst();
      if (model == null) {
        throw StateError('No hay registro de stock en el camion para producto $productoId');
      }
      model.cantidad += cantidad;
      await isar.inventarioCamionModels.put(model);
    });

    final updated = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo(productoId)
        .findFirst();
    if (updated != null) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.update, jsonEncode(updated.toJson()));
    }
  }
}

InventoryRepository createInventoryRepository() => IsarInventoryRepository();
