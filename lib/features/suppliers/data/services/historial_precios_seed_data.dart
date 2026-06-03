import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

class HistorialPreciosSeedData {
  static final List<HistorialPrecio> demoHistorial = [
    HistorialPrecio(
      id: 1,
      productoId: '1',
      proveedorId: '1',
      precioCompra: 45000,
      fechaRegistro: DateTime(2026, 1, 15),
    ),
    HistorialPrecio(
      id: 2,
      productoId: '2',
      proveedorId: '1',
      precioCompra: 120000,
      fechaRegistro: DateTime(2026, 1, 20),
    ),
    HistorialPrecio(
      id: 3,
      productoId: '1',
      proveedorId: '2',
      precioCompra: 42000,
      fechaRegistro: DateTime(2026, 2, 1),
    ),
  ];
}