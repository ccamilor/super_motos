import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/services/facturas_seed_data.dart';
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
    if (models.isEmpty) {
      await _seedDemoData(isar);
      models = await isar.facturaModels.where().sortByFechaDesc().findAll();
    }

    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Factura> create(Factura factura) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = FacturaModel.fromDomain(factura)..numeroFactura = Isar.autoIncrement;
    await isar.writeTxn(() async {
      await isar.facturaModels.put(model);
    });
    final saved = await isar.facturaModels.get(model.numeroFactura);
    SyncService.instance.enqueue('facturas', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Factura?> getById(int numeroFactura) async {
    final isar = _isar;
    if (isar == null) {
      return null;
    }

    final model = await isar.facturaModels.get(numeroFactura);
    return model?.toDomain();
  }

  @override
  Future<void> delete(int numeroFactura) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = await isar.facturaModels.get(numeroFactura);
    final json = model != null ? jsonEncode(model.toJson()) : '{"numero_factura":"$numeroFactura"}';

    await isar.writeTxn(() async {
      await isar.facturaModels.delete(numeroFactura);
    });
    SyncService.instance.enqueue('facturas', SyncOperation.delete, json);
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final factura in FacturasSeedData.demoFacturas) {
        final model = FacturaModel.fromDomain(factura)
          ..numeroFactura = Isar.autoIncrement;
        final assignedId = await isar.facturaModels.put(model);
        model.numeroFactura = assignedId;
      }
    });
  }
}

FacturasRepository createFacturasRepository() => IsarFacturasRepository();
