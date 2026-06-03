import 'package:isar/isar.dart';
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

    final model = ClienteModel.fromDomain(cliente)..id = Isar.autoIncrement;
    await isar.writeTxn(() async {
      await isar.clienteModels.put(model);
    });
    final saved = await isar.clienteModels.get(model.id);
    return saved!.toDomain();
  }

  @override
  Future<Cliente> update(Cliente cliente) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    final model = ClienteModel.fromDomain(cliente);
    await isar.writeTxn(() async {
      await isar.clienteModels.put(model);
    });
    return model.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    final isar = _isar;
    if (isar == null) {
      throw StateError('Isar no esta inicializado.');
    }

    await isar.writeTxn(() async {
      await isar.clienteModels.delete(id);
    });
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final cliente in ClientesSeedData.demoClientes) {
        final model = ClienteModel.fromDomain(cliente)
          ..id = Isar.autoIncrement;
        final assignedId = await isar.clienteModels.put(model);
        model.id = assignedId;
      }
    });
  }
}

ClientesRepository createClientesRepository() => IsarClientesRepository();
