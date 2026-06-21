import 'package:isar/isar.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';

part 'recepcion_model.g.dart';

@embedded
class DetalleRecepcionModel {
  String? productoId;
  int? cantidad;
  double? precioUnitario;
  String? destino;
  int? cantidadCamion;
  int? cantidadBodega;

  DetalleRecepcionModel();

  DetalleRecepcion toDomain() {
    return DetalleRecepcion(
      productoId: productoId ?? '',
      cantidad: cantidad ?? 0,
      precioUnitario: precioUnitario ?? 0.0,
      destino: destino ?? 'camion',
      cantidadCamion: cantidadCamion,
      cantidadBodega: cantidadBodega,
    );
  }

  static DetalleRecepcionModel fromDomain(DetalleRecepcion domain) {
    return DetalleRecepcionModel()
      ..productoId = domain.productoId
      ..cantidad = domain.cantidad
      ..precioUnitario = domain.precioUnitario
      ..destino = domain.destino
      ..cantidadCamion = domain.cantidadCamion
      ..cantidadBodega = domain.cantidadBodega;
  }
}

@collection
class RecepcionModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String proveedorId;
  late DateTime fecha;
  String? nroRemito;
  String? observaciones;
  List<DetalleRecepcionModel>? detalles;
  bool isSynced = false;

  Recepcion toDomain() {
    return Recepcion(
      codigo: codigo,
      proveedorId: proveedorId,
      fecha: fecha,
      nroRemito: nroRemito,
      observaciones: observaciones,
      detalles: detalles?.map((d) => d.toDomain()).toList() ?? [],
      isSynced: isSynced,
    );
  }

  static RecepcionModel fromDomain(Recepcion domain) {
    return RecepcionModel()
      ..codigo = domain.codigo
      ..proveedorId = domain.proveedorId
      ..fecha = domain.fecha
      ..nroRemito = domain.nroRemito
      ..observaciones = domain.observaciones
      ..detalles = domain.detalles.map((d) => DetalleRecepcionModel.fromDomain(d)).toList()
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'proveedor_id': proveedorId,
      'fecha': fecha.toIso8601String(),
      'nro_remito': nroRemito,
      'observaciones': observaciones,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
