import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';

class FacturasSeedData {
  static final List<Factura> demoFacturas = [
    Factura(
      codigo: 'FAC-001',
      clienteId: 'CLI-001',
      vendedorId: 'USR-001',
      fecha: DateTime.now().subtract(const Duration(days: 10)),
      total: 92000,
      tipoPago: TipoPago.contado,
      detalles: const [
        DetalleFactura(productoId: 'PROD-003', cantidad: 2, precioUnitario: 35000, subtotal: 70000),
        DetalleFactura(productoId: 'PROD-006', cantidad: 1, precioUnitario: 22000, subtotal: 22000),
      ],
    ),
    Factura(
      codigo: 'FAC-002',
      clienteId: 'CLI-002',
      vendedorId: 'USR-001',
      fecha: DateTime.now().subtract(const Duration(days: 3)),
      total: 185000,
      tipoPago: TipoPago.credito,
      detalles: const [
        DetalleFactura(productoId: 'PROD-005', cantidad: 1, precioUnitario: 185000, subtotal: 185000),
      ],
    ),
  ];
}
