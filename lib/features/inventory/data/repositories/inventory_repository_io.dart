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
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

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
  Future<void> decrementCamionStock(String productoId, int cantidad) async {
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

      final producto = await isar.productoModels
          .filter()
          .codigoEqualTo(productoId)
          .findFirst();
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
  Future<InventorySnapshot> createProduct(InventoryEntry entry) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no está inicializado.');
    }

    final producto = entry.toProductoModel();
    final camion = entry.toCamionModel();
    final bodega = entry.toBodegaModel();

    await isar.writeTxn(() async {
      await isar.productoModels.put(producto);
      if (entry.cantidadCamion > 0) {
        await isar.inventarioCamionModels.put(camion);
      }
      if (entry.cantidadBodega > 0) {
        await isar.inventarioBodegaModels.put(bodega);
      }
    });

    SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(producto.toJson()));
    if (entry.cantidadCamion > 0) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.insert, jsonEncode(camion.toJson()));
    }
    if (entry.cantidadBodega > 0) {
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.insert, jsonEncode(bodega.toJson()));
    }

    return loadInventory();
  }

  @override
  Future<InventorySnapshot> updateProduct(InventoryEntry entry) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no está inicializado.');
    }

    final existingProducto = await isar.productoModels
        .filter().codigoEqualTo(entry.codigo).findFirst();
    final producto = entry.toProductoModel();
    if (existingProducto != null) {
      producto.id = existingProducto.id;
    }
    final camion = entry.toCamionModel();
    final bodega = entry.toBodegaModel();

    await isar.writeTxn(() async {
      await isar.productoModels.put(producto);
      final existingCamion = await isar.inventarioCamionModels
          .filter().productoIdEqualTo(entry.codigo).findFirst();
      if (existingCamion != null) {
        if (entry.cantidadCamion > 0) {
          await isar.inventarioCamionModels.put(camion);
        } else {
          await isar.inventarioCamionModels.delete(existingCamion.id);
        }
      } else if (entry.cantidadCamion > 0) {
        await isar.inventarioCamionModels.put(camion);
      }
      final existingBodega = await isar.inventarioBodegaModels
          .filter().productoIdEqualTo(entry.codigo).findFirst();
      if (existingBodega != null) {
        if (entry.cantidadBodega > 0) {
          await isar.inventarioBodegaModels.put(bodega);
        } else {
          await isar.inventarioBodegaModels.delete(existingBodega.id);
        }
      } else if (entry.cantidadBodega > 0) {
        await isar.inventarioBodegaModels.put(bodega);
      }
    });

    SyncService.instance.enqueue('productos', SyncOperation.update, jsonEncode(producto.toJson()));
    final savedCamion = await isar.inventarioCamionModels
        .filter().productoIdEqualTo(entry.codigo).findFirst();
    if (savedCamion != null) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.update, jsonEncode(savedCamion.toJson()));
    } else if (entry.cantidadCamion > 0) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.insert, jsonEncode(camion.toJson()));
    }
    final savedBodega = await isar.inventarioBodegaModels
        .filter().productoIdEqualTo(entry.codigo).findFirst();
    if (savedBodega != null) {
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.update, jsonEncode(savedBodega.toJson()));
    } else if (entry.cantidadBodega > 0) {
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.insert, jsonEncode(bodega.toJson()));
    }

    return loadInventory();
  }

  @override
  Future<InventorySnapshot> deleteProduct(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no está inicializado.');
    }

    await isar.writeTxn(() async {
      final producto = await isar.productoModels
          .filter().codigoEqualTo(codigo).findFirst();
      if (producto != null) {
        await isar.productoModels.delete(producto.id);
      }
      final camion = await isar.inventarioCamionModels
          .filter().productoIdEqualTo(codigo).findFirst();
      if (camion != null) {
        await isar.inventarioCamionModels.delete(camion.id);
      }
      final bodega = await isar.inventarioBodegaModels
          .filter().productoIdEqualTo(codigo).findFirst();
      if (bodega != null) {
        await isar.inventarioBodegaModels.delete(bodega.id);
      }
    });

    SyncService.instance.enqueue('productos', SyncOperation.delete, jsonEncode({'codigo': codigo}));
    SyncService.instance.enqueue('inventario_camion', SyncOperation.delete, jsonEncode({'producto_id': codigo}));
    SyncService.instance.enqueue('inventario_bodega', SyncOperation.delete, jsonEncode({'producto_id': codigo}));

    return loadInventory();
  }

  @override
  Future<void> incrementCamionStock(String productoId, int cantidad) async {
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
