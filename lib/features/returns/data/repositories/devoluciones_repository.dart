import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

abstract class DevolucionesRepository {
  Future<List<Devolucion>> loadAll();
  Future<Devolucion> create(Devolucion devolucion);
  Future<Devolucion?> getByCodigo(String codigo);
  Future<void> delete(String codigo);
}
