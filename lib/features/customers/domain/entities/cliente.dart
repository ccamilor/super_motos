import 'package:super_motos/core/enums/estado_cuenta.dart';

class Cliente {
  final String codigo;
  final String nombre;
  final String identificadorFiscal;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final double limiteCredito;
  final double saldoPendiente;
  final EstadoCuenta estadoCuenta;
  final bool isSynced;

  const Cliente({
    required this.codigo,
    required this.nombre,
    required this.identificadorFiscal,
    required this.direccion,
    this.latitud,
    this.longitud,
    required this.limiteCredito,
    required this.saldoPendiente,
    required this.estadoCuenta,
    this.isSynced = false,
  });

  Cliente copyWith({
    String? codigo,
    String? nombre,
    String? identificadorFiscal,
    String? direccion,
    double? latitud,
    double? longitud,
    double? limiteCredito,
    double? saldoPendiente,
    EstadoCuenta? estadoCuenta,
    bool? isSynced,
  }) {
    return Cliente(
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      identificadorFiscal: identificadorFiscal ?? this.identificadorFiscal,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      limiteCredito: limiteCredito ?? this.limiteCredito,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      estadoCuenta: estadoCuenta ?? this.estadoCuenta,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
