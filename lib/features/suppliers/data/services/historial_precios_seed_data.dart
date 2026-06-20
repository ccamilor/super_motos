import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';

class HistorialPreciosSeedData {
  static final List<HistorialPrecio> demoHistorial = [
    HistorialPrecio(
      codigo: 'HP-001',
      productoId: 'PROD-001',
      proveedorId: 'PROV-001',
      precioCompra: 45000,
      fechaRegistro: DateTime(2026, 1, 15),
    ),
    HistorialPrecio(
      codigo: 'HP-002',
      productoId: 'PROD-002',
      proveedorId: 'PROV-001',
      precioCompra: 120000,
      fechaRegistro: DateTime(2026, 1, 20),
    ),
    HistorialPrecio(
      codigo: 'HP-003',
      productoId: 'PROD-001',
      proveedorId: 'PROV-002',
      precioCompra: 42000,
      fechaRegistro: DateTime(2026, 2, 1),
    ),
  ];
}
