import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/services/devoluciones_seed_data.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

class IsarDevolucionesRepository implements DevolucionesRepository {
  Isar? get _isar => Isar.getInstance();

  @override
  Future<List<Devolucion>> loadAll() async {
    final isar = _isar;
    if (isar == null) {
      return [];
    }

    var models = await isar.devolucionModels.where().sortByFechaDevolucionDesc().findAll();
    if (models.isEmpty) {
      await _seedDemoData(isar);
      models = await isar.devolucionModels.where().sortByFechaDevolucionDesc().findAll();
    }

    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Devolucion> create(Devolucion devolucion) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = DevolucionModel.fromDomain(devolucion);
    await isar.writeTxn(() async {
      await isar.devolucionModels.put(model);
    });
    final saved = await isar.devolucionModels.filter().codigoEqualTo(devolucion.codigo).findFirst();
    SyncService.instance.enqueue('devoluciones', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Devolucion?> getByCodigo(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      return null;
    }

    final model = await isar.devolucionModels.filter().codigoEqualTo(codigo).findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> delete(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = await isar.devolucionModels.filter().codigoEqualTo(codigo).findFirst();
    final json = model != null ? jsonEncode(model.toJson()) : '{"codigo":"$codigo"}';

    await isar.writeTxn(() async {
      if (model != null) {
        await isar.devolucionModels.delete(model.id);
      }
    });
    SyncService.instance.enqueue('devoluciones', SyncOperation.delete, json);
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final devolucion in DevolucionesSeedData.demoDevoluciones) {
        final model = DevolucionModel.fromDomain(devolucion);
        final existing = await isar.devolucionModels.filter().codigoEqualTo(model.codigo).findFirst();
        if (existing != null) model.id = existing.id;
        await isar.devolucionModels.put(model);
      }
    });
  }
}

DevolucionesRepository createDevolucionesRepository() => IsarDevolucionesRepository();
