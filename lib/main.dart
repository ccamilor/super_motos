import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_motos/core/database/isar_service.dart';
import 'package:super_motos/core/services/stock_alert_service.dart';
import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/core/theme/app_theme.dart';
import 'package:super_motos/features/auth/presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.init();
  final isarService = IsarService();
  await isarService.init();
  await SyncService.instance.init();
  unawaited(SyncService.instance.pullAll());
  if (!kIsWeb) {
    await StockAlertService.instance.init();
    await StockAlertService.instance.requestPermissions();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoRuta Pro',
      debugShowCheckedModeBanner: false,
      theme: JapaniRacerTheme.darkTheme,
      darkTheme: JapaniRacerTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const AuthWrapper(),
      },
    );
  }
}   