import 'package:isar/isar.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

part 'devolucion_model.g.dart';

@collection
class DevolucionModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String facturaId;
  late String productoId;
  late int cantidad;
  late String canastaDestino;
  late DateTime fechaDevolucion;
  late String motivo;
  bool isSynced = false;

  Devolucion toDomain() {
    return Devolucion(
      codigo: codigo,
      facturaId: facturaId,
      productoId: productoId,
      cantidad: cantidad,
      canastaDestino: canastaDestino,
      fechaDevolucion: fechaDevolucion,
      motivo: motivo,
      isSynced: isSynced,
    );
  }

  static DevolucionModel fromDomain(Devolucion domain) {
    return DevolucionModel()
      ..codigo = domain.codigo
      ..facturaId = domain.facturaId
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad
      ..canastaDestino = domain.canastaDestino
      ..fechaDevolucion = domain.fechaDevolucion
      ..motivo = domain.motivo
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'factura_id': facturaId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'canasta_destino': canastaDestino,
      'fecha_devolucion': fechaDevolucion.toIso8601String(),
      'motivo': motivo,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
