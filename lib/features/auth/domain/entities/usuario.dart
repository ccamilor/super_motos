import 'package:super_motos/core/enums/rol_usuario.dart';

class Usuario {
  final String codigo;
  final String nombre;
  final String email;
  final RolUsuario rol;

  Usuario({
    required this.codigo,
    required this.nombre,
    required this.email,
    required this.rol,
  });
}
