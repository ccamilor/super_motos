import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

class DevolucionesSeedData {
  static final List<Devolucion> demoDevoluciones = [
    Devolucion(
      id: 1,
      facturaId: '1',
      productoId: '3',
      cantidad: 1,
      numeroCanastaDestino: 'A2',
      fechaDevolucion: DateTime.now().subtract(const Duration(days: 5)),
      motivo: 'Defecto de fabrica',
    ),
    Devolucion(
      id: 2,
      facturaId: '2',
      productoId: '5',
      cantidad: 1,
      numeroCanastaDestino: 'B1',
      fechaDevolucion: DateTime.now().subtract(const Duration(days: 1)),
      motivo: 'Producto incorrecto',
    ),
  ];
}
