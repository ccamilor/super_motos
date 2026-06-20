import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void setUsuario(Usuario usuario) {
    _currentUser = usuario;
  }

  void clear() {
    _currentUser = null;
  }

  static final List<Usuario> _hardcodedUsers = [
    Usuario(
      codigo: 'USR-001',
      nombre: 'Mayra',
      email: 'mayra@supermotos.com',
      rol: RolUsuario.admin,
    ),
    Usuario(
      codigo: 'USR-002',
      nombre: 'Mateo',
      email: 'mateo@supermotos.com',
      rol: RolUsuario.vendedor,
    ),
  ];

  List<Usuario> get hardcodedUsers => List.unmodifiable(_hardcodedUsers);
}
