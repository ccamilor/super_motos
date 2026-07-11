import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/stock_alert_service.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_exporter.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';
import 'package:super_motos/core/utils/import_progress.dart';

class IsarInventoryRepository implements InventoryRepository {
  Isar? get _isar => Isar.getInstance();
  final InventoryCsvParser _parser = const InventoryCsvParser();
  final InventoryCsvExporter _exporter = const InventoryCsvExporter();

  @override
  Future<InventorySnapshot> loadInventory() async {
    final isar = _isar;
    if (isar == null) {
      return InventorySnapshot.empty;
    }

    var productos = await isar.productoModels.where().findAll();

    final camion = await isar.inventarioCamionModels.where().findAll();
    final bodega = await isar.inventarioBodegaModels.where().findAll();

    return InventorySnapshot(
      productos: productos,
      camion: camion,
      bodega: bodega,
    );
  }

  @override
  Future<InventorySnapshot> importCsv(String csvContent, {
    void Function(ImportProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no está inicializado.');
    }

    final entries = _parser.parse(csvContent);
    if (entries.isEmpty) {
      throw FormatException('El CSV está vacío o no contiene filas válidas.');
    }

    // Reemplazar completamente el inventario local para evitar datos demo persistentes.
    await isar.writeTxn(() async {
      await isar.productoModels.where().deleteAll();
      await isar.inventarioCamionModels.where().deleteAll();
      await isar.inventarioBodegaModels.where().deleteAll();
    });

    const chunkSize = 500;
    final total = entries.length;
    int processed = 0;

    // Report initial progress
    onProgress?.call(ImportProgress(processed: 0, total: total));

    // Process in chunks
    for (int i = 0; i < total; i += chunkSize) {
      if (cancelToken?.isCancelled == true) {
        throw StateError('Importación cancelada por el usuario');
      }

      final chunk = entries.skip(i).take(chunkSize).toList();

      await isar.writeTxn(() async {
        for (final entry in chunk) {
          if (cancelToken?.isCancelled == true) {
            throw StateError('Importación cancelada por el usuario');
          }
          final pModel = entry.toProductoModel();
          final existingP = await isar.productoModels.filter().codigoEqualTo(pModel.codigo).findFirst();
          if (existingP != null) pModel.id = existingP.id;
          await isar.productoModels.put(pModel);

          final cModel = entry.toCamionModel();
          final existingC = await isar.inventarioCamionModels.filter().codigoEqualTo(cModel.codigo).findFirst();
          if (existingC != null) cModel.id = existingC.id;
          await isar.inventarioCamionModels.put(cModel);

          final bModel = entry.toBodegaModel();
          final existingB = await isar.inventarioBodegaModels.filter().codigoEqualTo(bModel.codigo).findFirst();
          if (existingB != null) bModel.id = existingB.id;
          await isar.inventarioBodegaModels.put(bModel);
        }
      });

      for (final entry in chunk) {
        if (cancelToken?.isCancelled == true) {
          throw StateError('Importación cancelada por el usuario');
        }

        final savedP = await isar.productoModels.filter().codigoEqualTo(entry.codigo).findFirst();
        if (savedP != null) {
          SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(savedP.toJson()));
        }

        final savedC = await isar.inventarioCamionModels.filter().codigoEqualTo(entry.toCamionModel().codigo).findFirst();
        if (savedC != null) {
          SyncService.instance.enqueue('inventario_camion', SyncOperation.insert, jsonEncode(savedC.toJson()));
        }

        final savedB = await isar.inventarioBodegaModels.filter().codigoEqualTo(entry.toBodegaModel().codigo).findFirst();
        if (savedB != null) {
          SyncService.instance.enqueue('inventario_bodega', SyncOperation.insert, jsonEncode(savedB.toJson()));
        }
      }

      processed += chunk.length;
      onProgress?.call(ImportProgress(
        processed: processed,
        total: total,
        currentItem: chunk.last.nombre,
      ));

      // Small delay to keep UI responsive
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // Final progress
    onProgress?.call(ImportProgress(
      processed: total,
      total: total,
      done: true,
    ));

    return loadInventory();
  }

  @override
  Future<String> exportCsv() async {
    final snapshot = await loadInventory();
    final entries = <InventoryEntry>[];

    for (final producto in snapshot.productos) {
      final camion = snapshot.camion.firstWhere(
        (c) => c.productoId == producto.codigo,
        orElse: () => InventarioCamionModel()
          ..productoId = producto.codigo
          ..cantidad = 0
          ..canastaId = '0',
      );
      final bodega = snapshot.bodega.firstWhere(
        (b) => b.productoId == producto.codigo,
        orElse: () => InventarioBodegaModel()
          ..productoId = producto.codigo
          ..cantidad = 0,
      );

      entries.add(InventoryEntry(
        codigo: producto.codigo,
        nombre: producto.nombre,
        precio: producto.precio,
        isOriginal: producto.isOriginal,
        motosCompatibles: producto.motosCompatibles,
        stockMinimo: producto.stockMinimo,
        cantidadCamion: camion.cantidad,
        canastaId: camion.canastaId,
        cantidadBodega: bodega.cantidad,
      ));
    }

    return _exporter.export(entries);
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
      final productoParaSync = await isar.productoModels.filter().codigoEqualTo(productoId).findFirst();
      if (productoParaSync != null) {
        SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(productoParaSync.toJson()));
      }
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
          camion.id = existingCamion.id;
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
          bodega.id = existingBodega.id;
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
      final productoParaSync = await isar.productoModels.filter().codigoEqualTo(productoId).findFirst();
      if (productoParaSync != null) {
        SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(productoParaSync.toJson()));
      }
      SyncService.instance.enqueue('inventario_camion', SyncOperation.update, jsonEncode(updated.toJson()));
    }
  }

  @override
  Future<void> incrementBodegaStock(String productoId, int cantidad) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    await isar.writeTxn(() async {
      final model = await isar.inventarioBodegaModels
          .filter()
          .productoIdEqualTo(productoId)
          .findFirst();
      if (model == null) {
        throw StateError('No hay registro de stock en la bodega para producto $productoId');
      }
      model.cantidad += cantidad;
      await isar.inventarioBodegaModels.put(model);
    });

    final updated = await isar.inventarioBodegaModels
        .filter()
        .productoIdEqualTo(productoId)
        .findFirst();
    if (updated != null) {
      final productoParaSync = await isar.productoModels.filter().codigoEqualTo(productoId).findFirst();
      if (productoParaSync != null) {
        SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(productoParaSync.toJson()));
      }
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.update, jsonEncode(updated.toJson()));
    }
  }

  @override
  Future<void> createProductFromRecepcion(String productoId, int cantCamion, int cantBodega) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    // Verificar si el producto ya existe
    final existingProducto = await isar.productoModels.filter().codigoEqualTo(productoId).findFirst();
    if (existingProducto != null) return; // Ya existe, no hacer nada

    // Crear entrada mínima en producto (solo para FK)
    final productoModel = ProductoModel()
      ..codigo = productoId
      ..nombre = 'Producto $productoId'
      ..precio = 0
      ..isOriginal = false
      ..motosCompatibles = ''
      ..stockMinimo = 0;

    await isar.writeTxn(() async {
      await isar.productoModels.put(productoModel);
      if (cantCamion > 0) {
        await isar.inventarioCamionModels.put(InventarioCamionModel()
          ..codigo = '${productoId}_CAMION'
          ..productoId = productoId
          ..canastaId = '0'
          ..cantidad = cantCamion);
      }
      if (cantBodega > 0) {
        await isar.inventarioBodegaModels.put(InventarioBodegaModel()
          ..codigo = '${productoId}_BODEGA'
          ..productoId = productoId
          ..cantidad = cantBodega);
      }
    });

    SyncService.instance.enqueue('productos', SyncOperation.insert, jsonEncode(productoModel.toJson()));
    if (cantCamion > 0) {
      SyncService.instance.enqueue('inventario_camion', SyncOperation.insert, 
        jsonEncode((await isar.inventarioCamionModels.filter().productoIdEqualTo(productoId).findFirst())!.toJson()));
    }
    if (cantBodega > 0) {
      SyncService.instance.enqueue('inventario_bodega', SyncOperation.insert,
        jsonEncode((await isar.inventarioBodegaModels.filter().productoIdEqualTo(productoId).findFirst())!.toJson()));
    }
  }
}

InventoryRepository createInventoryRepository() => IsarInventoryRepository();
