import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

part 'cliente_model.g.dart';

@collection
class ClienteModel {
  Id id = Isar.autoIncrement;
  late String nombre;
  late String identificadorFiscal;
  late String direccion;
  double? latitud;
  double? longitud;
  late double limiteCredito;
  late double saldoPendiente;
  late String estadoCuenta;

  Cliente toDomain() {
    return Cliente(
      id: id,
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
    );
  }

  static ClienteModel fromDomain(Cliente domain) {
    return ClienteModel()
      ..id = domain.id
      ..nombre = domain.nombre
      ..identificadorFiscal = domain.identificadorFiscal
      ..direccion = domain.direccion
      ..latitud = domain.latitud
      ..longitud = domain.longitud
      ..limiteCredito = domain.limiteCredito
      ..saldoPendiente = domain.saldoPendiente
      ..estadoCuenta = domain.estadoCuenta.name;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'identificador_fiscal': identificadorFiscal,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'limite_credito': limiteCredito,
      'saldo_pendiente': saldoPendiente,
      'estado_cuenta': estadoCuenta,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
