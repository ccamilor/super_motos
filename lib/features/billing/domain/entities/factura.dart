class DetalleFactura {
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleFactura({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });
}

class Factura {
  final int numeroFactura;
  final int clienteId;
  final int vendedorId;
  final DateTime fecha;
  final double total;
  final String tipoPago;
  final double? latitudVenta;
  final double? longitudVenta;
  final List<DetalleFactura> detalles;
  final bool isSynced;

  Factura({
    required this.numeroFactura,
    required this.clienteId,
    required this.vendedorId,
    required this.fecha,
    required this.total,
    required this.tipoPago,
    this.latitudVenta,
    this.longitudVenta,
    required this.detalles,
    this.isSynced = false,
  });
}
