import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/features/auth/domain/entities/usuario.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient _client;
  bool _initialized = false;

  SupabaseClient get client => _client;

  static const String _supabaseUrl = 'https://skybcdetpah1btakusyf.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNreWJjZGV0cGFobGJ0YWt1c3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA1MTk3OTQsImV4cCI6MjA5NjA5NTc5NH0.QSPTCMpf1vlvEgVzgFDSDTm_lGk7Fa_VZr3zh_hzeDc';

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _client = Supabase.instance.client;
    _initialized = true;
  }

  bool get isAuthenticated => _client.auth.currentUser != null;

  Future<Usuario?> signInWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) return null;
    return _getUsuarioFromUser(response.user!);
  }

  Future<Usuario?> signUp(String email, String password, String nombre, String rol) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'rol': rol,
      },
    );
    if (response.user == null) return null;
    return _getUsuarioFromUser(response.user!);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Usuario?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _getUsuarioFromUser(user);
  }

  Usuario _getUsuarioFromUser(User user) {
    final rolStr = user.userMetadata?['rol'] as String? ?? 'vendedor';
    return Usuario(
      id: int.tryParse(user.id.substring(0, 8), radix: 16) ?? 0,
      nombre: user.userMetadata?['nombre'] as String? ?? user.email ?? 'Usuario',
      email: user.email ?? '',
      rol: rolStr == 'admin' ? RolUsuario.admin : RolUsuario.vendedor,
    );
  }
}