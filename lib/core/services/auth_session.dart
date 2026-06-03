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
      id: 1,
      nombre: 'Mayra',
      email: 'admin@super_motos.com',
      rol: RolUsuario.admin,
    ),
    Usuario(
      id: 2,
      nombre: 'Mateo',
      email: 'vendedor@super_motos.com',
      rol: RolUsuario.vendedor,
    ),
  ];

  List<Usuario> get hardcodedUsers => List.unmodifiable(_hardcodedUsers);
}