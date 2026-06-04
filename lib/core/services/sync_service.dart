import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/supabase_service.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const String _queueKey = 'super_motos_sync_queue';
  static const Duration _pushInterval = Duration(seconds: 10);

  List<SyncQueueItem> _queue = [];
  Timer? _pushTimer;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadQueue();
    _startPushTimer();
    _initialized = true;
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _queue = list.map((e) => SyncQueueItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _queue = [];
    }
  }

  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_queueKey, raw);
    } catch (e) {
      debugPrint('SyncService: failed to save queue: $e');
    }
  }

  void enqueue(String table, SyncOperation operation, String recordJson) {
    final item = SyncQueueItem(
      id: DateTime.now().millisecondsSinceEpoch,
      table: table,
      operation: operation,
      recordJson: recordJson,
      createdAt: DateTime.now(),
    );
    _queue.add(item);
    _saveQueue();
    _tryPushOne();
  }

  void _startPushTimer() {
    _pushTimer?.cancel();
    _pushTimer = Timer.periodic(_pushInterval, (_) => _tryPushAll());
  }

  Future<void> _tryPushOne() async {
    if (_queue.isEmpty) return;
    final pending = _queue.where((item) => !item.synced).toList();
    if (pending.isEmpty) return;

    final item = pending.first;
    final success = await _pushItem(item);
    if (success) {
      _queue.remove(item);
      await _saveQueue();
    }
  }

  Future<void> _tryPushAll() async {
    if (_queue.isEmpty) return;
    final pending = _queue.where((item) => !item.synced).toList();
    for (final item in pending) {
      final success = await _pushItem(item);
      if (success) {
        _queue.remove(item);
      }
    }
    await _saveQueue();
  }

  Future<bool> _pushItem(SyncQueueItem item) async {
    try {
      final client = SupabaseService.instance.client;

      switch (item.operation) {
        case SyncOperation.insert:
        case SyncOperation.update:
          await _upsertRecord(client, item);
          break;
        case SyncOperation.delete:
          await _deleteRecord(client, item);
          break;
      }

      item.markSynced();
      return true;
    } catch (e) {
      debugPrint('SyncService: failed to push ${item.table}/${item.operation}: $e');
      return false;
    }
  }

  Future<void> _upsertRecord(dynamic client, SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    switch (item.table) {
      case 'clientes':
        await client.from('clientes').upsert(record, onConflict: 'id');
        break;
      case 'facturas':
        await client.from('facturas').upsert(record, onConflict: 'id');
        break;
      case 'detalles_factura':
        await client.from('detalles_factura').upsert(record, onConflict: 'id');
        break;
      case 'devoluciones':
        await client.from('devoluciones').upsert(record, onConflict: 'id');
        break;
      case 'proveedores':
        await client.from('proveedores').upsert(record, onConflict: 'id');
        break;
      case 'historial_precios':
        await client.from('historial_precios').upsert(record, onConflict: 'id');
        break;
      case 'productos':
        await client.from('productos').upsert(record, onConflict: 'id');
        break;
    }
  }

  Future<void> _deleteRecord(dynamic client, SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    final id = record['id']?.toString();
    if (id == null) return;

    switch (item.table) {
      case 'clientes':
        await client.from('clientes').delete().eq('id', id);
        break;
      case 'facturas':
        await client.from('facturas').delete().eq('id', id);
        break;
      case 'devoluciones':
        await client.from('devoluciones').delete().eq('id', id);
        break;
      case 'proveedores':
        await client.from('proveedores').delete().eq('id', id);
        break;
    }
  }

  Future<void> pullAll() async {
    try {
      final client = SupabaseService.instance.client;
      await _pullTable(client, 'clientes');
      await _pullTable(client, 'facturas');
      await _pullTable(client, 'devoluciones');
      await _pullTable(client, 'proveedores');
      await _pullTable(client, 'historial_precios');
    } catch (e) {
      debugPrint('SyncService: pullAll failed: $e');
    }
  }

  Future<void> _pullTable(dynamic client, String table) async {
    try {
      final response = await client.from(table).select();
      if (response == null) return;
    } catch (e) {
      debugPrint('SyncService: pull $table failed: $e');
    }
  }

  int get queueLength => _queue.length;
  List<SyncQueueItem> get pendingItems => List.unmodifiable(_queue);

  void dispose() {
    _pushTimer?.cancel();
  }
}