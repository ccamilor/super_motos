import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

class IsarHistorialPreciosRepository implements HistorialPreciosRepository {
  Isar? get _isar => Isar.getInstance();

  @override
  Future<List<HistorialPrecio>> loadAll() async {
    final isar = _isar;
    if (isar == null) return [];
    final models = await isar.historialPreciosModels.where().findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<HistorialPrecio>> loadByProveedorId(String proveedorId) async {
    final isar = _isar;
    if (isar == null) return [];
    final models = await isar.historialPreciosModels
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .sortByFechaRegistroDesc()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<HistorialPrecio> create(HistorialPrecio historial) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final model = HistorialPreciosModel.fromDomain(historial);
    await isar.writeTxn(() async {
      await isar.historialPreciosModels.put(model);
    });
    final saved = await isar.historialPreciosModels.filter().codigoEqualTo(historial.codigo).findFirst();
    SyncService.instance.enqueue('historial_precios', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<void> delete(String codigo) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final model = await isar.historialPreciosModels.filter().codigoEqualTo(codigo).findFirst();
    final json = model != null ? jsonEncode(model.toJson()) : '{"codigo":"$codigo"}';
    await isar.writeTxn(() async {
      if (model != null) {
        await isar.historialPreciosModels.delete(model.id);
      }
    });
    SyncService.instance.enqueue('historial_precios', SyncOperation.delete, json);
  }

  @override
  Future<void> deleteByProveedorId(String proveedorId) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final models = await isar.historialPreciosModels
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .findAll();
    for (final model in models) {
      SyncService.instance.enqueue('historial_precios', SyncOperation.delete, jsonEncode(model.toJson()));
    }
    await isar.writeTxn(() async {
      await isar.historialPreciosModels
          .filter()
          .proveedorIdEqualTo(proveedorId)
          .deleteAll();
    });
  }

  @override
  Future<HistorialPrecio> upsertPrecio({
    required String proveedorId,
    required String productoId,
    required double precioCompra,
  }) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');

    // Buscar si ya existe un registro para este proveedor+producto
    final existing = await isar.historialPreciosModels
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .productoIdEqualTo(productoId)
        .findFirst();

    HistorialPreciosModel model;
    if (existing != null) {
      model = existing
        ..precioCompra = precioCompra
        ..fechaRegistro = DateTime.now()
        ..isSynced = false;
    } else {
      model = HistorialPreciosModel()
        ..codigo = 'HP-${DateTime.now().millisecondsSinceEpoch}'
        ..proveedorId = proveedorId
        ..productoId = productoId
        ..precioCompra = precioCompra
        ..fechaRegistro = DateTime.now()
        ..isSynced = false;
    }

    await isar.writeTxn(() async {
      await isar.historialPreciosModels.put(model);
    });

    final saved = await isar.historialPreciosModels
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .productoIdEqualTo(productoId)
        .findFirst();
    
    SyncService.instance.enqueue('historial_precios', SyncOperation.update, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }
}

HistorialPreciosRepository createHistorialPreciosRepository() =>
    IsarHistorialPreciosRepository();
