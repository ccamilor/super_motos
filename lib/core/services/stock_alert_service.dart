import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockAlertService {
  StockAlertService._();
  static final StockAlertService instance = StockAlertService._();

  static const String _lowStockCountKey = 'super_motos_low_stock_count';
  static const String _channelId = 'stock_alerts';
  static const String _channelName = 'Alertas de Stock';
  static const String _channelDesc = 'Notificaciones cuando el stock del camion esta bajo el minimo';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> checkAndNotify({
    required int productoId,
    required String productoNombre,
    required int nuevaCantidad,
    required int stockMinimo,
  }) async {
    if (nuevaCantidad < stockMinimo) {
      await _incrementLowStockCount();
      await _showNotification(
        id: productoId,
        title: 'Stock Bajo',
        body: '$productoNombre — quedan $nuevaCantidad und. Min: $stockMinimo',
      );
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(id, title, body, details);
    } catch (e) {
      debugPrint('StockAlertService: failed to show notification: $e');
    }
  }

  Future<void> _incrementLowStockCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_lowStockCountKey) ?? 0;
      await prefs.setInt(_lowStockCountKey, count + 1);
    } catch (e) {
      debugPrint('StockAlertService: failed to update low stock count: $e');
    }
  }

  Future<int> getLowStockAlertCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lowStockCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearLowStockAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lowStockCountKey, 0);
    } catch (e) {
      debugPrint('StockAlertService: failed to clear low stock count: $e');
    }
  }

  Future<void> updateLowStockCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lowStockCountKey, count);
    } catch (e) {
      debugPrint('StockAlertService: failed to set low stock count: $e');
    }
  }
}