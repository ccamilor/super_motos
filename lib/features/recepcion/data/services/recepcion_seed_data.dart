import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';

class RecepcionSeedData {
  static final List<Recepcion> demoRecepciones = [
    Recepcion(
      codigo: 'REC-001',
      proveedorId: 'PROV-001',
      fecha: DateTime.now().subtract(const Duration(days: 10)),
      nroRemito: 'RM-1001',
      observaciones: 'Entrega completa kit arrastre + bujias',
      detalles: [
        DetalleRecepcion(
          productoId: 'PROD-001',
          cantidad: 50,
          precioUnitario: 42000,
          destino: 'camion',
        ),
        DetalleRecepcion(
          productoId: 'PROD-003',
          cantidad: 30,
          precioUnitario: 9500,
          destino: 'bodega',
        ),
      ],
    ),
    Recepcion(
      codigo: 'REC-002',
      proveedorId: 'PROV-002',
      fecha: DateTime.now().subtract(const Duration(days: 3)),
      nroRemito: 'RM-2050',
      observaciones: 'Split: pastillas a camion, filtros a bodega',
      detalles: [
        DetalleRecepcion(
          productoId: 'PROD-002',
          cantidad: 40,
          precioUnitario: 11000,
          destino: 'split',
          cantidadCamion: 15,
          cantidadBodega: 25,
        ),
        DetalleRecepcion(
          productoId: 'PROD-004',
          cantidad: 20,
          precioUnitario: 13500,
          destino: 'bodega',
        ),
      ],
    ),
  ];
}
