import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

class ClientesSeedData {
  static const List<Cliente> demoClientes = [
    Cliente(
      id: 1,
      nombre: 'Tienda Don Repuesto',
      identificadorFiscal: '900123456',
      direccion: 'Cra 15 #45-30, Bogota',
      limiteCredito: 5000000,
      saldoPendiente: 1250000,
      estadoCuenta: EstadoCuenta.activo,
    ),
    Cliente(
      id: 2,
      nombre: 'Moto Servicio El Veloz',
      identificadorFiscal: '800987654',
      direccion: 'Calle 7 #22-10, Medellin',
      limiteCredito: 2000000,
      saldoPendiente: 2500000,
      estadoCuenta: EstadoCuenta.sinCredito,
    ),
    Cliente(
      id: 3,
      nombre: 'Repuestos La Esquina',
      identificadorFiscal: '700555333',
      direccion: 'Av 30 #50-15, Cali',
      limiteCredito: 3000000,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.suspendido,
    ),
  ];
}
