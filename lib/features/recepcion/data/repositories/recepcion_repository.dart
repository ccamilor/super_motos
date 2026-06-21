import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';

abstract class RecepcionRepository {
  Future<List<Recepcion>> loadAll();
  Future<List<Recepcion>> loadByProveedor(String proveedorId);
  Future<Recepcion> create(Recepcion recepcion);
  Future<Recepcion?> getByCodigo(String codigo);
  Future<void> delete(String codigo);
}
