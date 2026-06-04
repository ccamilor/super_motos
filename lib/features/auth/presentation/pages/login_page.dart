import 'package:flutter/material.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/core/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _supabase = SupabaseService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  static const List<_QuickUser> _quickUsers = [
    _QuickUser(email: 'mayra@supermotos.com', password: 'super_motos2024', nombre: 'Mayra', rol: RolUsuario.admin),
    _QuickUser(email: 'mateo@supermotos.com', password: 'super_motos2024', nombre: 'Mateo', rol: RolUsuario.vendedor),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithQuickUser(_QuickUser user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hardcodedUser = AuthSession.instance.hardcodedUsers.firstWhere(
        (u) => u.email == user.email,
        orElse: () => throw Exception('Usuario no encontrado'),
      );
      AuthSession.instance.setUsuario(hardcodedUser);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usuario = await _supabase.signInWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (usuario == null) {
        setState(() => _errorMessage = 'Credenciales inválidas');
        return;
      }

      if (!mounted) return;
      AuthSession.instance.setUsuario(usuario);
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al iniciar sesión: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                'ACCESO RAPIDO',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ..._quickUsers.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickUserCard(user: u, onTap: () => _loginWithQuickUser(u)),
              )),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'o ingresa con tu cuenta',
                  style: TextStyle(color: colorScheme.outlineVariant, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'tu@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'El email es obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                        hintText: '********',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'La contrasena es obligatoria' : null,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: colorScheme.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Iniciar sesion', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickUser {
  final String email;
  final String password;
  final String nombre;
  final RolUsuario rol;

  const _QuickUser({
    required this.email,
    required this.password,
    required this.nombre,
    required this.rol,
  });
}

class _QuickUserCard extends StatelessWidget {
  const _QuickUserCard({required this.user, required this.onTap});

  final _QuickUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAdmin = user.rol == RolUsuario.admin;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAdmin ? 'Administrador' : 'Vendedor',
                    style: TextStyle(
                      color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.outlineVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}