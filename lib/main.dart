import 'package:flutter/material.dart';
import 'package:super_motos/core/database/isar_service.dart';
import 'package:super_motos/features/home/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  await isarService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Motos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ), // // ThemeData
      home: const DashboardPage(), // <-- Mira lo limpio que queda
    ); // // MaterialApp
  }
}
