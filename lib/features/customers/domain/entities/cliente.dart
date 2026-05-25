import 'package:super_motos/core/enums/estado_cuenta.dart';

class Cliente {
  final int id;
  final String nombre;
  final String identificadorFiscal;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final double limiteCredito;
  final double saldoPendiente;
  final EstadoCuenta estadoCuenta;

  Cliente({
    required this.id,
    required this.nombre,
    required this.identificadorFiscal,
    required this.direccion,
    this.latitud,
    this.longitud,
    required this.limiteCredito,
    required this.saldoPendiente,
    required this.estadoCuenta,
  });
}
