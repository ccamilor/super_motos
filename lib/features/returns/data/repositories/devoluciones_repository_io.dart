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

    final model = DevolucionModel.fromDomain(devolucion)..id = Isar.autoIncrement;
    await isar.writeTxn(() async {
      await isar.devolucionModels.put(model);
    });
    final saved = await isar.devolucionModels.get(model.id);
    SyncService.instance.enqueue('devoluciones', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Devolucion?> getById(int id) async {
    final isar = _isar;
    if (isar == null) {
      return null;
    }

    final model = await isar.devolucionModels.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = await isar.devolucionModels.get(id);
    final json = model != null ? jsonEncode(model.toJson()) : '{"id":"$id"}';

    await isar.writeTxn(() async {
      await isar.devolucionModels.delete(id);
    });
    SyncService.instance.enqueue('devoluciones', SyncOperation.delete, json);
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final devolucion in DevolucionesSeedData.demoDevoluciones) {
        final model = DevolucionModel.fromDomain(devolucion)..id = Isar.autoIncrement;
        final assignedId = await isar.devolucionModels.put(model);
        model.id = assignedId;
      }
    });
  }
}

DevolucionesRepository createDevolucionesRepository() => IsarDevolucionesRepository();
