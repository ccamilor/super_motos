import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';

class IsarFacturasRepository implements FacturasRepository {
  Isar? get _isar => Isar.getInstance();

  @override
  Future<List<Factura>> loadAll() async {
    final isar = _isar;
    if (isar == null) {
      return [];
    }

    var models = await isar.facturaModels.where().sortByFechaDesc().findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Factura> create(Factura factura) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = FacturaModel.fromDomain(factura);
    await isar.writeTxn(() async {
      await isar.facturaModels.put(model);
    });
    final saved = await isar.facturaModels.filter().codigoEqualTo(factura.codigo).findFirst();
    SyncService.instance.enqueue('facturas', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Factura> update(Factura factura) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final existing = await isar.facturaModels.filter().codigoEqualTo(factura.codigo).findFirst();
    final model = FacturaModel.fromDomain(factura);
    if (existing != null) {
      model.id = existing.id;
    }
    model.isSynced = false;
    await isar.writeTxn(() async {
      await isar.facturaModels.put(model);
    });
    final saved = await isar.facturaModels.filter().codigoEqualTo(factura.codigo).findFirst();
    SyncService.instance.enqueue('facturas', SyncOperation.update, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Factura?> getByCodigo(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      return null;
    }

    final model = await isar.facturaModels.filter().codigoEqualTo(codigo).findFirst();
    return model?.toDomain();
  }

  @override
  Future<void> delete(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = await isar.facturaModels.filter().codigoEqualTo(codigo).findFirst();
    final json = model != null ? jsonEncode(model.toJson()) : '{"codigo":"$codigo"}';

    await isar.writeTxn(() async {
      if (model != null) {
        await isar.facturaModels.delete(model.id);
      }
    });
    SyncService.instance.enqueue('facturas', SyncOperation.delete, json);
  }

}

FacturasRepository createFacturasRepository() => IsarFacturasRepository();
