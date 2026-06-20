import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

part 'cliente_model.g.dart';

@collection
class ClienteModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String nombre;
  late String identificadorFiscal;
  late String direccion;
  double? latitud;
  double? longitud;
  late double limiteCredito;
  late double saldoPendiente;
  late String estadoCuenta;
  bool isSynced = false;

  Cliente toDomain() {
    return Cliente(
      codigo: codigo,
      nombre: nombre,
      identificadorFiscal: identificadorFiscal,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
      limiteCredito: limiteCredito,
      saldoPendiente: saldoPendiente,
      estadoCuenta: EstadoCuenta.values.firstWhere(
        (e) => e.name == estadoCuenta,
        orElse: () => EstadoCuenta.activo,
      ),
      isSynced: isSynced,
    );
  }

  static ClienteModel fromDomain(Cliente domain) {
    return ClienteModel()
      ..codigo = domain.codigo
      ..nombre = domain.nombre
      ..identificadorFiscal = domain.identificadorFiscal
      ..direccion = domain.direccion
      ..latitud = domain.latitud
      ..longitud = domain.longitud
      ..limiteCredito = domain.limiteCredito
      ..saldoPendiente = domain.saldoPendiente
      ..estadoCuenta = domain.estadoCuenta.name
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'identificador_fiscal': identificadorFiscal,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'limite_credito': limiteCredito,
      'saldo_pendiente': saldoPendiente,
      'estado_cuenta': estadoCuenta,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
