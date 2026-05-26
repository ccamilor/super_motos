import 'package:isar/isar.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

part 'devolucion_model.g.dart';

@collection
class DevolucionModel {
  Id id = Isar.autoIncrement;
  late String facturaId;
  late String productoId;
  late int cantidad;
  late String numeroCanastaDestino;
  late DateTime fechaDevolucion;
  late String motivo;
  bool isSynced = false;

  Devolucion toDomain() {
    return Devolucion(
      id: id,
      facturaId: facturaId,
      productoId: productoId,
      cantidad: cantidad,
      numeroCanastaDestino: numeroCanastaDestino,
      fechaDevolucion: fechaDevolucion,
      motivo: motivo,
      isSynced: isSynced,
    );
  }

  static DevolucionModel fromDomain(Devolucion domain) {
    return DevolucionModel()
      ..id = domain.id
      ..facturaId = domain.facturaId
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad
      ..numeroCanastaDestino = domain.numeroCanastaDestino
      ..fechaDevolucion = domain.fechaDevolucion
      ..motivo = domain.motivo
      ..isSynced = domain.isSynced;
  }
}
