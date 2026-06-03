import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/services/proveedores_seed_data.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class IsarProveedoresRepository implements ProveedoresRepository {
  Isar? get _isar => Isar.getInstance();

  @override
  Future<List<Proveedor>> loadAll() async {
    final isar = _isar;
    if (isar == null) return [];
    var models = await isar.proveedorModels.where().sortByNombre().findAll();
    if (models.isEmpty) {
      await _seedDemoData(isar);
      models = await isar.proveedorModels.where().sortByNombre().findAll();
    }
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Proveedor> create(Proveedor proveedor) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final model = ProveedorModel.fromDomain(proveedor)..id = Isar.autoIncrement;
    await isar.writeTxn(() async {
      await isar.proveedorModels.put(model);
    });
    final saved = await isar.proveedorModels.get(model.id);
    return saved!.toDomain();
  }

  @override
  Future<Proveedor> update(Proveedor proveedor) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final model = ProveedorModel.fromDomain(proveedor);
    await isar.writeTxn(() async {
      await isar.proveedorModels.put(model);
    });
    return model.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    await isar.writeTxn(() async {
      await isar.proveedorModels.delete(id);
    });
  }

  Future<void> _seedDemoData(Isar isar) async {
    await isar.writeTxn(() async {
      for (final proveedor in ProveedoresSeedData.demoProveedores) {
        final model = ProveedorModel.fromDomain(proveedor)
          ..id = Isar.autoIncrement;
        final assignedId = await isar.proveedorModels.put(model);
        model.id = assignedId;
      }
    });
  }
}

ProveedoresRepository createProveedoresRepository() => IsarProveedoresRepository();