import 'package:super_motos/features/billing/domain/entities/factura.dart';

abstract class FacturasRepository {
  Future<List<Factura>> loadAll();
  Future<Factura> create(Factura factura);
  Future<Factura?> getById(int numeroFactura);
  Future<void> delete(int numeroFactura);
}
