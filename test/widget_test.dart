import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';
import 'package:super_motos/main.dart';

void main() {
  testWidgets('MyApp renders the dashboard shell after login', (WidgetTester tester) async {
    AuthSession.instance.setUsuario(Usuario(
      codigo: 'USR-001',
      nombre: 'Test Admin',
      email: 'admin@test.com',
      rol: RolUsuario.admin,
    ));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MotoRuta Pro'), findsOneWidget);
    expect(find.byIcon(Icons.two_wheeler), findsOneWidget);
    expect(find.text('T'), findsOneWidget);

    AuthSession.instance.clear();
  });
}