import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';

part 'usuario_model.g.dart';

@collection
class UsuarioModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String nombre;
  late String email;
  late String rol;

  Usuario toDomain() {
    return Usuario(
      codigo: codigo,
      nombre: nombre,
      email: email,
      rol: RolUsuario.values.firstWhere(
        (e) => e.name == rol,
        orElse: () => RolUsuario.vendedor,
      ),
    );
  }

  static UsuarioModel fromDomain(Usuario domain) {
    return UsuarioModel()
      ..codigo = domain.codigo
      ..nombre = domain.nombre
      ..email = domain.email
      ..rol = domain.rol.name;
  }
}
