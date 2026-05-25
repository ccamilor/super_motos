import 'package:super_motos/core/enums/rol_usuario.dart';

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final RolUsuario rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });
}
