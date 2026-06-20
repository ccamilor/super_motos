import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class ProveedoresSeedData {
  static final List<Proveedor> demoProveedores = [
    Proveedor(
      codigo: 'PROV-001',
      nombre: 'Repuestos Moto JC',
      nit: '900111222',
      telefono: '3001234567',
      direccion: 'Cra 15 #45-30, Bogota',
    ),
    Proveedor(
      codigo: 'PROV-002',
      nombre: 'Distribuidora Pegasus',
      nit: '800333444',
      telefono: '3009876543',
      direccion: 'Calle 7 #22-10, Medellin',
    ),
    Proveedor(
      codigo: 'PROV-003',
      nombre: 'Importados El Sol',
      nit: '700555666',
      telefono: '3005551234',
      direccion: 'Av 30 #50-15, Cali',
    ),
  ];
}
