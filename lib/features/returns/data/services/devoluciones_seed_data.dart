import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

class DevolucionesSeedData {
  static final List<Devolucion> demoDevoluciones = [
    Devolucion(
      codigo: 'DEV-001',
      facturaId: 'FAC-001',
      productoId: 'PROD-003',
      cantidad: 1,
      canastaDestino: 'A-2',
      fechaDevolucion: DateTime.now().subtract(const Duration(days: 5)),
      motivo: 'Defecto de fabrica',
    ),
    Devolucion(
      codigo: 'DEV-002',
      facturaId: 'FAC-002',
      productoId: 'PROD-005',
      cantidad: 1,
      canastaDestino: 'B-1',
      fechaDevolucion: DateTime.now().subtract(const Duration(days: 1)),
      motivo: 'Producto incorrecto',
    ),
  ];
}
