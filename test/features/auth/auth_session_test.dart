import 'package:flutter_test/flutter_test.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';

void main() {
  test('defaultUser is null at startup', () {
    expect(AuthSession.instance.currentUser, isNull);
    expect(AuthSession.instance.isLoggedIn, isFalse);
  });

  test('setUsuario assigns the active user', () {
    final usuario = Usuario(
      codigo: 'USR-001',
      nombre: 'Test User',
      email: 'test@test.com',
      rol: RolUsuario.admin,
    );

    AuthSession.instance.setUsuario(usuario);

    expect(AuthSession.instance.currentUser, isNotNull);
    expect(AuthSession.instance.currentUser!.nombre, equals('Test User'));
    expect(AuthSession.instance.isLoggedIn, isTrue);
  });

  test('clear() resets to null', () {
    final usuario = Usuario(
      codigo: 'USR-001',
      nombre: 'Test User',
      email: 'test@test.com',
      rol: RolUsuario.vendedor,
    );

    AuthSession.instance.setUsuario(usuario);
    expect(AuthSession.instance.isLoggedIn, isTrue);

    AuthSession.instance.clear();

    expect(AuthSession.instance.currentUser, isNull);
    expect(AuthSession.instance.isLoggedIn, isFalse);
  });

  test('hardcodedUsers returns exactly 2 users', () {
    final users = AuthSession.instance.hardcodedUsers;
    expect(users, hasLength(2));
    expect(users[0].rol, equals(RolUsuario.admin));
    expect(users[1].rol, equals(RolUsuario.vendedor));
  });

  test('hardcodedUsers are unmodifiable', () {
    final users = AuthSession.instance.hardcodedUsers;
    expect(() => users.add(Usuario(
      codigo: 'USR-003',
      nombre: 'Extra',
      email: 'extra@test.com',
      rol: RolUsuario.vendedor,
    )), throwsUnsupportedError);
  });
}