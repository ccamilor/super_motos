import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';

class Recepcion {
  final String codigo;
  final String proveedorId;
  final DateTime fecha;
  final String? nroRemito;
  final String? observaciones;
  final List<DetalleRecepcion> detalles;
  final bool isSynced;

  const Recepcion({
    required this.codigo,
    required this.proveedorId,
    required this.fecha,
    this.nroRemito,
    this.observaciones,
    required this.detalles,
    this.isSynced = false,
  });

  double get total => detalles.fold(0.0, (sum, d) => sum + d.subtotal);

  Recepcion copyWith({
    String? codigo,
    String? proveedorId,
    DateTime? fecha,
    String? nroRemito,
    String? observaciones,
    List<DetalleRecepcion>? detalles,
    bool? isSynced,
  }) {
    return Recepcion(
      codigo: codigo ?? this.codigo,
      proveedorId: proveedorId ?? this.proveedorId,
      fecha: fecha ?? this.fecha,
      nroRemito: nroRemito ?? this.nroRemito,
      observaciones: observaciones ?? this.observaciones,
      detalles: detalles ?? this.detalles,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
