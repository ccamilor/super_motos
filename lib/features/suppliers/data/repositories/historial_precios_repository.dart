import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

abstract class HistorialPreciosRepository {
  Future<List<HistorialPrecio>> loadAll();
  Future<List<HistorialPrecio>> loadByProveedorId(String proveedorId);
  Future<HistorialPrecio> create(HistorialPrecio historial);
  Future<HistorialPrecio> upsertPrecio({required String proveedorId, required String productoId, required double precioCompra});
  Future<void> delete(String codigo);
  Future<void> deleteByProveedorId(String proveedorId);
}
