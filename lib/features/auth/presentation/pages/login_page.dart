import 'package:flutter/material.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final users = AuthSession.instance.hardcodedUsers;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.two_wheeler_rounded,
                      size: 72,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'MotoRuta Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Inicia sesion para continuar',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'SELECCIONA TU USUARIO',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ...users.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _UserCard(usuario: u),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdmin = usuario.rol == RolUsuario.admin;

    return InkWell(
      onTap: () => _login(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAdmin
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAdmin ? 'Administrador' : 'Vendedor',
                    style: TextStyle(
                      color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.outlineVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    AuthSession.instance.setUsuario(usuario);
    Navigator.of(context).pushReplacementNamed('/home');
  }
}