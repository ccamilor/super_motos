import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';

part 'factura_model.g.dart';

@embedded
class DetalleFacturaModel {
  int? productoId;
  int? cantidad;
  double? precioUnitario;
  double? subtotal;

  DetalleFacturaModel();

  DetalleFactura toDomain() {
    return DetalleFactura(
      productoId: productoId ?? 0,
      cantidad: cantidad ?? 0,
      precioUnitario: precioUnitario ?? 0.0,
      subtotal: subtotal ?? 0.0,
    );
  }

  static DetalleFacturaModel fromDomain(DetalleFactura domain) {
    return DetalleFacturaModel()
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad
      ..precioUnitario = domain.precioUnitario
      ..subtotal = domain.subtotal;
  }
}

@collection
class FacturaModel {
  Id numeroFactura = Isar.autoIncrement;
  late int clienteId;
  late int vendedorId;
  late DateTime fecha;
  late double total;
  late String tipoPago;
  double? latitudVenta;
  double? longitudVenta;
  List<DetalleFacturaModel>? detalles;
  bool isSynced = false;

  Factura toDomain() {
    return Factura(
      numeroFactura: numeroFactura,
      clienteId: clienteId,
      vendedorId: vendedorId,
      fecha: fecha,
      total: total,
      tipoPago: TipoPago.values.firstWhere(
        (e) => e.name == tipoPago,
        orElse: () => TipoPago.contado,
      ),
      latitudVenta: latitudVenta,
      longitudVenta: longitudVenta,
      detalles: detalles?.map((d) => d.toDomain()).toList() ?? [],
      isSynced: isSynced,
    );
  }

  static FacturaModel fromDomain(Factura domain) {
    return FacturaModel()
      ..numeroFactura = domain.numeroFactura
      ..clienteId = domain.clienteId
      ..vendedorId = domain.vendedorId
      ..fecha = domain.fecha
      ..total = domain.total
      ..tipoPago = domain.tipoPago.name
      ..latitudVenta = domain.latitudVenta
      ..longitudVenta = domain.longitudVenta
      ..detalles = domain.detalles.map((d) => DetalleFacturaModel.fromDomain(d)).toList()
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_factura': numeroFactura,
      'cliente_id': clienteId,
      'vendedor_id': vendedorId,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'tipo_pago': tipoPago,
      'latitud_venta': latitudVenta,
      'longitud_venta': longitudVenta,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
