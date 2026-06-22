import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_log_service.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/supabase_service.dart';

enum ConflictResolution { serverWins, lastWriteWins }

enum SyncStatus { synced, syncing, error }

class SyncResult {
  final SyncStatus status;
  final int pushed;
  final int failed;
  final int totalPending;
  final DateTime timestamp;

  SyncResult({
    required this.status,
    required this.pushed,
    required this.failed,
    required this.totalPending,
    required this.timestamp,
  });
}

class ConflictInfo {
  final String table;
  final String recordId;
  final DateTime localUpdatedAt;
  final DateTime serverUpdatedAt;
  final Map<String, dynamic> serverRecord;

  const ConflictInfo({
    required this.table,
    required this.recordId,
    required this.localUpdatedAt,
    required this.serverUpdatedAt,
    required this.serverRecord,
  });

  bool get serverIsNewer => serverUpdatedAt.isAfter(localUpdatedAt);
  bool get localIsNewer => localUpdatedAt.isAfter(serverUpdatedAt);
}

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const String _queueKey = 'super_motos_sync_queue';
  static const Duration _basePushInterval = Duration(seconds: 10);
  static const int _maxRetries = 5;

  List<SyncQueueItem> _queue = [];
  Timer? _pushTimer;
  bool _initialized = false;
  bool _canSync = false;
  ConflictResolution _conflictResolution = ConflictResolution.lastWriteWins;

  final ValueNotifier<SyncResult> syncResultNotifier = ValueNotifier<SyncResult>(
    SyncResult(status: SyncStatus.synced, pushed: 0, failed: 0, totalPending: 0, timestamp: DateTime(2000)),
  );
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  Future<void> init() async {
    if (_initialized) return;
    await createSyncLogService().init();
    await _loadQueue();
    _startPushTimer();
    _canSync = true;
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
    
    final record = jsonDecode(recordJson) as Map<String, dynamic>;
    final recordId = record['codigo']?.toString() ?? record['id']?.toString() ?? 'unknown';
    
    createSyncLogService().logSyncEvent(SyncLogEntry(
      timestamp: DateTime.now(),
      table: table,
      operation: operation.name,
      recordId: recordId,
      status: SyncLogStatus.pending,
    ));
    
    if (_canSync) {
      _saveQueue();
      _tryPushOne();
    }
  }

  void _startPushTimer() {
    _pushTimer?.cancel();
    final hasRetryingItems = _queue.any((item) => !item.synced && item.retryCount > 0);
    final interval = hasRetryingItems ? _calculateBackoffInterval() : _basePushInterval;
    _pushTimer = Timer.periodic(interval, (_) => _tryPushAll());
  }

  Duration _calculateBackoffInterval() {
    final maxRetryCount = _queue
        .where((item) => !item.synced && item.retryCount > 0)
        .map((item) => item.retryCount)
        .fold(0, (max, count) => count > max ? count : max);
    
    final backoffSeconds = _basePushInterval.inSeconds * (1 << (maxRetryCount - 1));
    final cappedSeconds = backoffSeconds > 300 ? 300 : backoffSeconds;
    return Duration(seconds: cappedSeconds);
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
    _isSyncing = true;
    _notifySyncing();

    final pending = _queue.where((item) => !item.synced).toList();
    int pushed = 0;
    int failed = 0;

    for (final item in pending) {
      final result = await _pushItemWithRetry(item);
      if (result) {
        _queue.remove(item);
        pushed++;
      } else {
        failed++;
      }
    }
    await _saveQueue();
    
    _startPushTimer();

    _isSyncing = false;
    _notifyResult(pushed: pushed, failed: failed);
  }

  Future<bool> _pushItemWithRetry(SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    final recordId = record['codigo']?.toString() ?? record['id']?.toString() ?? 'unknown';
    
    final logs = await createSyncLogService().getLogs(
      table: item.table,
      limit: 1000,
    );
    
    final existingLog = logs.firstWhere(
      (log) => log.recordId == recordId && log.operation == item.operation.name,
      orElse: () => SyncLogEntry(
        timestamp: DateTime.now(),
        table: item.table,
        operation: item.operation.name,
        recordId: recordId,
        status: SyncLogStatus.pending,
      ),
    );
    
    if (item.retryCount >= _maxRetries) {
      await createSyncLogService().updateLogStatus(
        existingLog.id ?? -1,
        SyncLogStatus.permanentFailed,
        errorMessage: 'Max retries ($_maxRetries) exceeded',
        retryCount: item.retryCount,
      );
      item.markSynced();
      return true;
    }
    
    if (item.retryCount > 0) {
      await createSyncLogService().updateLogStatus(
        existingLog.id ?? -1,
        SyncLogStatus.retrying,
        retryCount: item.retryCount,
      );
    }
    
    final success = await _pushItem(item);
    
    if (success) {
      await createSyncLogService().updateLogStatus(
        existingLog.id ?? -1,
        SyncLogStatus.synced,
        retryCount: item.retryCount,
      );
      return true;
    } else {
      item.retryCount++;
      await createSyncLogService().updateLogStatus(
        existingLog.id ?? -1,
        item.retryCount >= _maxRetries ? SyncLogStatus.permanentFailed : SyncLogStatus.failed,
        errorMessage: 'Push failed',
        retryCount: item.retryCount,
      );
      return false;
    }
  }

  Future<bool> _pushItem(SyncQueueItem item) async {
    try {
      final client = SupabaseService.instance.client;

      if (item.operation == SyncOperation.insert || item.operation == SyncOperation.update) {
        final conflict = await _checkForConflict(client, item);
        if (conflict != null) {
          if (conflict.serverIsNewer && _conflictResolution == ConflictResolution.serverWins) {
            debugPrint('SyncService: conflict detected, server wins for ${item.table}/${item.recordJson.hashCode}');
            item.markSynced();
            return true;
          }
          if (conflict.serverIsNewer && _conflictResolution == ConflictResolution.lastWriteWins) {
            debugPrint('SyncService: conflict detected, local is older — pushing anyway (last-write-wins)');
          }
        }
        await _upsertRecord(client, item);
      } else {
        await _deleteRecord(client, item);
      }

      item.markSynced();
      return true;
    } catch (e) {
      debugPrint('SyncService: failed to push ${item.table}/${item.operation}: $e');
      return false;
    }
  }

  Future<ConflictInfo?> _checkForConflict(dynamic client, SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    final idField = item.table == 'facturas' ? 'codigo' : 'codigo';
    final id = record[idField]?.toString();
    if (id == null) return null;

    try {
      dynamic response;
      if (item.table == 'facturas') {
        response = await client.from(item.table).select().eq('codigo', id).maybeSingle();
      } else {
        response = await client.from(item.table).select().eq('codigo', id).maybeSingle();
      }
      if (response == null) return null;

      final serverUpdatedAtStr = response['updated_at'] as String?;
      final localUpdatedAtStr = record['updated_at'] as String?;
      if (serverUpdatedAtStr == null || localUpdatedAtStr == null) return null;

      final serverUpdatedAt = DateTime.parse(serverUpdatedAtStr);
      final localUpdatedAt = DateTime.parse(localUpdatedAtStr);

      if (serverUpdatedAt.isAfter(localUpdatedAt)) {
        return ConflictInfo(
          table: item.table,
          recordId: id,
          localUpdatedAt: localUpdatedAt,
          serverUpdatedAt: serverUpdatedAt,
          serverRecord: Map<String, dynamic>.from(response),
        );
      }
    } catch (e) {
      // No conflict check possible, proceed with push
    }
    return null;
  }

  Future<void> _upsertRecord(dynamic client, SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    switch (item.table) {
      case 'clientes':
        await client.from('clientes').upsert(record, onConflict: 'codigo');
        break;
      case 'facturas':
        await client.from('facturas').upsert(record, onConflict: 'codigo');
        break;
      case 'detalles_factura':
        await client.from('detalles_factura').upsert(record, onConflict: 'codigo');
        break;
      case 'devoluciones':
        await client.from('devoluciones').upsert(record, onConflict: 'codigo');
        break;
      case 'proveedores':
        await client.from('proveedores').upsert(record, onConflict: 'codigo');
        break;
      case 'historial_precios':
        await client.from('historial_precios').upsert(record, onConflict: 'codigo');
        break;
      case 'productos':
        await client.from('productos').upsert(record, onConflict: 'codigo');
        break;
      case 'inventario_camion':
        await client.from('inventario_camion').upsert(record, onConflict: 'codigo');
        break;
      case 'inventario_bodega':
        await client.from('inventario_bodega').upsert(record, onConflict: 'codigo');
        break;
      case 'recepciones':
        await client.from('recepciones').upsert(record, onConflict: 'codigo');
        break;
      case 'detalles_recepcion':
        await client.from('detalles_recepcion').upsert(record, onConflict: 'codigo');
        break;
    }
  }

  Future<void> _deleteRecord(dynamic client, SyncQueueItem item) async {
    final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
    final idField = 'codigo';
    final id = record[idField]?.toString();
    if (id == null) return;

    switch (item.table) {
      case 'clientes':
        await client.from('clientes').delete().eq('codigo', id);
        break;
      case 'facturas':
        await client.from('facturas').delete().eq('codigo', id);
        break;
      case 'devoluciones':
        await client.from('devoluciones').delete().eq('codigo', id);
        break;
      case 'proveedores':
        await client.from('proveedores').delete().eq('codigo', id);
        break;
      case 'historial_precios':
        await client.from('historial_precios').delete().eq('codigo', id);
        break;
      case 'productos':
        await client.from('productos').delete().eq('codigo', id);
        break;
      case 'recepciones':
        await client.from('recepciones').delete().eq('codigo', id);
        break;
      case 'detalles_recepcion':
        await client.from('detalles_recepcion').delete().eq('codigo', id);
        break;
    }
  }

  Future<void> pullAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _notifySyncing();
    try {
      final client = SupabaseService.instance.client;
      await _pullTable(client, 'clientes');
      await _pullTable(client, 'facturas');
      await _pullTable(client, 'devoluciones');
      await _pullTable(client, 'proveedores');
      await _pullTable(client, 'historial_precios');
      await _pullTable(client, 'productos');
      await _pullTable(client, 'inventario_camion');
      await _pullTable(client, 'inventario_bodega');
      await _pullTable(client, 'recepciones');
      await _pullTable(client, 'detalles_recepcion');
      _isSyncing = false;
      _notifyResult(pushed: 0, failed: 0);
    } catch (e) {
      debugPrint('SyncService: pullAll failed: $e');
      _isSyncing = false;
      _notifyResult(pushed: 0, failed: 1);
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

  int getUnsyncedCount(String table) {
    return _queue.where((item) => item.table == table && !item.synced).length;
  }

  List<SyncQueueItem> getUnsyncedItems(String table) {
    return _queue.where((item) => item.table == table && !item.synced).toList();
  }

  bool isRecordPending(String table, String recordId) {
    return _queue.any((item) =>
        item.table == table &&
        !item.synced &&
        item.recordJson.contains(recordId));
  }

  void setConflictResolution(ConflictResolution resolution) {
    _conflictResolution = resolution;
  }

  void _notifySyncing() {
    syncResultNotifier.value = SyncResult(
      status: SyncStatus.syncing,
      pushed: 0,
      failed: 0,
      totalPending: 0,
      timestamp: DateTime(2000),
    );
  }

  void _notifyResult({required int pushed, required int failed}) {
    final status = failed > 0 ? SyncStatus.error : SyncStatus.synced;
    syncResultNotifier.value = SyncResult(
      status: status,
      pushed: pushed,
      failed: failed,
      totalPending: queueLength,
      timestamp: DateTime.now(),
    );
  }

  Future<void> forcePushAll() async {
    if (_isSyncing) return;
    _tryPushAll();
  }

  void dispose() {
    _pushTimer?.cancel();
  }

  void resetResultNotifier() {
    syncResultNotifier.value = SyncResult(
      status: SyncStatus.synced,
      pushed: 0,
      failed: 0,
      totalPending: 0,
      timestamp: DateTime(2000),
    );
  }
}