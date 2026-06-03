import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

abstract class DevolucionesRepository {
  Future<List<Devolucion>> loadAll();
  Future<Devolucion> create(Devolucion devolucion);
  Future<Devolucion?> getById(int id);
  Future<void> delete(int id);
}
