import 'package:super_motos/features/billing/domain/entities/factura.dart';

abstract class FacturasRepository {
  Future<List<Factura>> loadAll();
  Future<Factura> create(Factura factura);
  Future<Factura> update(Factura factura);
  Future<Factura?> getByCodigo(String codigo);
  Future<void> delete(String codigo);
}
