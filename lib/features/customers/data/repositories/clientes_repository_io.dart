import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/customers/data/models/cliente_model.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/services/clientes_seed_data.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

class IsarClientesRepository implements ClientesRepository {
  Isar? get _isar => Isar.getInstance();

  @override
  Future<List<Cliente>> loadAll() async {
    final isar = _isar;
    if (isar == null) {
      return [];
    }

    var models = await isar.clienteModels.where().sortByNombre().findAll();
    if (models.isEmpty) {
      await _seedDemoData(isar);
      models = await isar.clienteModels.where().sortByNombre().findAll();
    }

    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Cliente> create(Cliente cliente) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = ClienteModel.fromDomain(cliente);
    await isar.writeTxn(() async {
      await isar.clienteModels.put(model);
    });
    final saved = await isar.clienteModels.filter().codigoEqualTo(cliente.codigo).findFirst();
    SyncService.instance.enqueue('clientes', SyncOperation.insert, jsonEncode(saved!.toJson()));
    return saved.toDomain();
  }

  @override
  Future<Cliente> update(Cliente cliente) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final existing = await isar.clienteModels.filter().codigoEqualTo(cliente.codigo).findFirst();
    final model = ClienteModel.fromDomain(cliente);
    if (existing != null) {
      model.id = existing.id;
    }
    await isar.writeTxn(() async {
      await isar.clienteModels.put(model);
    });
    SyncService.instance.enqueue('clientes', SyncOperation.update, jsonEncode(model.toJson()));
    return model.toDomain();
  }

  @override
  Future<void> delete(String codigo) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = await isar.clienteModels.filter().codigoEqualTo(codigo).findFirst();
    final json = model != null ? jsonEncode(model.toJson()) : '{"codigo":"$codigo"}';

    await isar.writeTxn(() async {
      if (model != null) {
        await isar.clienteModels.delete(model.id);
      }
    });
    SyncService.instance.enqueue('clientes', SyncOperation.delete, json);
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final cliente in ClientesSeedData.demoClientes) {
        final model = ClienteModel.fromDomain(cliente);
        await isar.clienteModels.put(model);
      }
    });
  }
}

ClientesRepository createClientesRepository() => IsarClientesRepository();
