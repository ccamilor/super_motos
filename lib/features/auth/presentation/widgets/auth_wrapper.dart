import 'package:flutter/material.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/features/auth/presentation/pages/login_page.dart';
import 'package:super_motos/features/home/presentation/pages/dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthSession.instance.isLoggedIn) {
      return const DashboardPage();
    }
    return const LoginPage();
  }
}