import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

abstract class ProveedoresRepository {
  Future<List<Proveedor>> loadAll();
  Future<Proveedor> create(Proveedor proveedor);
  Future<Proveedor> update(Proveedor proveedor);
  Future<void> delete(String codigo);
}
