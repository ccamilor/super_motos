import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

abstract class HistorialPreciosRepository {
  Future<List<HistorialPrecio>> loadAll();
  Future<List<HistorialPrecio>> loadByProveedorId(int proveedorId);
  Future<HistorialPrecio> create(HistorialPrecio historial);
  Future<void> delete(int id);
  Future<void> deleteByProveedorId(int proveedorId);
}