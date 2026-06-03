import 'package:isar/isar.dart';
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
  Future<List<HistorialPrecio>> loadByProveedorId(int proveedorId) async {
    final isar = _isar;
    if (isar == null) return [];
    final models = await isar.historialPreciosModels
        .filter()
        .proveedorIdEqualTo(proveedorId.toString())
        .sortByFechaRegistroDesc()
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<HistorialPrecio> create(HistorialPrecio historial) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    final model = HistorialPreciosModel.fromDomain(historial)
      ..id = Isar.autoIncrement;
    await isar.writeTxn(() async {
      await isar.historialPreciosModels.put(model);
    });
    final saved = await isar.historialPreciosModels.get(model.id);
    return saved!.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    await isar.writeTxn(() async {
      await isar.historialPreciosModels.delete(id);
    });
  }

  @override
  Future<void> deleteByProveedorId(int proveedorId) async {
    final isar = _isar;
    if (isar == null) throw StateError('Isar no esta inicializado.');
    await isar.writeTxn(() async {
      await isar.historialPreciosModels
          .filter()
          .proveedorIdEqualTo(proveedorId.toString())
          .deleteAll();
    });
  }
}

HistorialPreciosRepository createHistorialPreciosRepository() =>
    IsarHistorialPreciosRepository();