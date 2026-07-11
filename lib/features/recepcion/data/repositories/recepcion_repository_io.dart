import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart';
import 'package:super_motos/features/recepcion/data/models/recepcion_model.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository_io.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository_web.dart';

class IsarRecepcionRepository implements RecepcionRepository {
  Isar? get _isar => Isar.getInstance();
  final InventoryRepository _inventoryRepo;
  final HistorialPreciosRepository _historialRepo;

  IsarRecepcionRepository({
    InventoryRepository? inventoryRepo,
    HistorialPreciosRepository? historialRepo,
  })  : _inventoryRepo = inventoryRepo ?? createInventoryRepository(),
        _historialRepo = historialRepo ?? createHistorialPreciosRepository();

  @override
  Future<List<Recepcion>> loadAll() async {
    final isar = _isar;
    if (isar == null) return [];

    var models = await isar.recepcionModels.where().sortByFechaDesc().findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<Recepcion>> loadByProveedor(String proveedorId) async {
    final isar = _isar;
    if (isar == null) return [];
    final models = await isar.recepcionModels
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .sortByFechaDesc()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Recepcion> create(Recepcion recepcion) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');

    for (final detalle in recepcion.detalles) {
      if (detalle.destino == 'split') {
        final sum = (detalle.cantidadCamion ?? 0) + (detalle.cantidadBodega ?? 0);
        if (sum != detalle.cantidad) {
          throw StateError(
            'Split invalido para ${detalle.productoId}: camion (${detalle.cantidadCamion}) + bodega (${detalle.cantidadBodega}) = $sum, debe ser ${detalle.cantidad}',
          );
        }
      }
    }

    final model = RecepcionModel.fromDomain(recepcion);
    await isar.writeTxn(() async {
      await isar.recepcionModels.put(model);
    });

    // Incrementar stock y actualizar HistorialPrecio
    for (final detalle in recepcion.detalles) {
      final cantCamion = _cantidadParaDestino(detalle, 'camion');
      final cantBodega = _cantidadParaDestino(detalle, 'bodega');

      if (cantCamion > 0) {
        try {
          await _inventoryRepo.incrementCamionStock(detalle.productoId, cantCamion);
        } catch (e) {
          // Producto no existe en inventario, crear entrada base
          await _inventoryRepo.createProductFromRecepcion(detalle.productoId, cantCamion, 0);
          await _inventoryRepo.incrementCamionStock(detalle.productoId, cantCamion);
        }
      }
      if (cantBodega > 0) {
        try {
          await _inventoryRepo.incrementBodegaStock(detalle.productoId, cantBodega);
        } catch (e) {
          await _inventoryRepo.createProductFromRecepcion(detalle.productoId, 0, cantBodega);
          await _inventoryRepo.incrementBodegaStock(detalle.productoId, cantBodega);
        }
      }

      // Upsert HistorialPrecio con precio real de la recepción
      await _historialRepo.upsertPrecio(
        proveedorId: recepcion.proveedorId,
        productoId: detalle.productoId,
        precioCompra: detalle.precioUnitario,
      );
    }

    final saved = await isar.recepcionModels.filter().codigoEqualTo(recepcion.codigo).findFirst();
    SyncService.instance.enqueue('recepciones', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Recepcion?> getByCodigo(String codigo) async {
    final isar = _isar;
    if (isar == null) return null;
    final model = await isar.recepcionModels.filter().codigoEqualTo(codigo).findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> delete(String codigo) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');

    final model = await isar.recepcionModels.filter().codigoEqualTo(codigo).findFirst();
    final json = model != null ? jsonEncode(model.toJson()) : '{"codigo":"$codigo"}';

    await isar.writeTxn(() async {
      if (model != null) {
        await isar.recepcionModels.delete(model.id);
      }
    });
    SyncService.instance.enqueue('recepciones', SyncOperation.delete, json);
  }

  int _cantidadParaDestino(dynamic detalle, String destino) {
    if (detalle.destino == 'split') {
      return destino == 'camion' ? (detalle.cantidadCamion ?? 0) : (detalle.cantidadBodega ?? 0);
    }
    return detalle.destino == destino ? detalle.cantidad : 0;
  }

}

RecepcionRepository createRecepcionRepository() => IsarRecepcionRepository();
