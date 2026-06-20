import 'package:super_motos/core/enums/tipo_pago.dart';

class DetalleFactura {
  final String productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const DetalleFactura({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  DetalleFactura copyWith({
    String? productoId,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
  }) {
    return DetalleFactura(
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

class Factura {
  final String codigo;
  final String clienteId;
  final String vendedorId;
  final DateTime fecha;
  final double total;
  final TipoPago tipoPago;
  final double? latitudVenta;
  final double? longitudVenta;
  final List<DetalleFactura> detalles;
  final bool isSynced;

  const Factura({
    required this.codigo,
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

  Factura copyWith({
    String? codigo,
    String? clienteId,
    String? vendedorId,
    DateTime? fecha,
    double? total,
    TipoPago? tipoPago,
    double? latitudVenta,
    double? longitudVenta,
    List<DetalleFactura>? detalles,
    bool? isSynced,
  }) {
    return Factura(
      codigo: codigo ?? this.codigo,
      clienteId: clienteId ?? this.clienteId,
      vendedorId: vendedorId ?? this.vendedorId,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      tipoPago: tipoPago ?? this.tipoPago,
      latitudVenta: latitudVenta ?? this.latitudVenta,
      longitudVenta: longitudVenta ?? this.longitudVenta,
      detalles: detalles ?? this.detalles,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
