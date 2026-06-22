import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_log_service.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/customers/data/models/cliente_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/recepcion/data/models/recepcion_model.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';

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
  String? get lastError => _lastError;
  String? _lastError;
  Isar? get _isar => Isar.getInstance();

  Future<void> init() async {
    if (_initialized) return;
    await createSyncLogService().init();
    await _loadQueue();
    _startPushTimer();
    _canSync = true;
    _initialized = true;
    _checkSupabaseConnection();
    _migrateUnsyncedProducts();
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      final client = SupabaseService.instance.client;
      await client.from('productos').select().limit(1);
      debugPrint('SyncService: Supabase conectado OK');
    } catch (e) {
      _lastError = 'Supabase: $e';
      debugPrint('SyncService: Supabase NO conectado: $e');
    }
  }

  Future<void> _migrateUnsyncedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('super_motos_unsynced_migrated') == true) return;

      final isar = _isar;
      if (isar == null) return;

      final productos = await isar.productoModels.filter().isSyncedEqualTo(false).findAll();
      final camion = await isar.inventarioCamionModels.filter().isSyncedEqualTo(false).findAll();
      final bodega = await isar.inventarioBodegaModels.filter().isSyncedEqualTo(false).findAll();

      for (final p in productos) {
        enqueue('productos', SyncOperation.insert, jsonEncode(p.toJson()));
      }
      for (final c in camion) {
        enqueue('inventario_camion', SyncOperation.insert, jsonEncode(c.toJson()));
      }
      for (final b in bodega) {
        enqueue('inventario_bodega', SyncOperation.insert, jsonEncode(b.toJson()));
      }

      await prefs.setBool('super_motos_unsynced_migrated', true);
    } catch (e) {
      debugPrint('SyncService: migrate unsynced products skipped: $e');
    }
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
    final record = jsonDecode(recordJson) as Map<String, dynamic>;
    final recordCodigo = record['codigo']?.toString();
    if (recordCodigo != null) {
      final exists = _queue.any((q) =>
          q.table == table &&
          !q.synced &&
          _extractCodigo(q) == recordCodigo);
      if (exists) return;
    }

    final item = SyncQueueItem(
      id: DateTime.now().millisecondsSinceEpoch,
      table: table,
      operation: operation,
      recordJson: recordJson,
      createdAt: DateTime.now(),
    );
    _queue.add(item);
    
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
      _notifyResult(pushed: 0, failed: 0);
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

  static const List<String> _pushOrder = [
    'productos',
    'clientes',
    'proveedores',
    'facturas',
    'detalles_factura',
    'inventario_camion',
    'inventario_bodega',
    'historial_precios',
    'recepciones',
    'detalles_recepcion',
    'devoluciones',
  ];

  List<SyncQueueItem> _sortedPending() {
    final pending = _queue.where((item) => !item.synced).toList();
    pending.sort((a, b) {
      final idxA = _pushOrder.indexOf(a.table);
      final idxB = _pushOrder.indexOf(b.table);
      return (idxA == -1 ? 999 : idxA).compareTo(idxB == -1 ? 999 : idxB);
    });
    return pending;
  }

  Future<void> _tryPushAll() async {
    if (_queue.isEmpty) return;
    _lastError = null;
    _isSyncing = true;
    _notifySyncing();

    final pending = _sortedPending();
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
      final isFkViolation = _lastError?.contains('23503') ?? false;
      if (!isFkViolation) {
        item.retryCount++;
      }
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
      await _markLocalAsSynced(item);
      return true;
    } catch (e) {
      _lastError = '${item.table}: $e';
      debugPrint('SyncService: failed to push ${item.table}/${item.operation}: $e');
      return false;
    }
  }

  Future<void> _markLocalAsSynced(SyncQueueItem item) async {
    final isar = _isar;
    if (isar == null) return;
    try {
      final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
      final codigo = record['codigo']?.toString();
      if (codigo == null) return;

      await isar.writeTxn(() async {
        switch (item.table) {
          case 'clientes':
            final m = await isar.clienteModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.clienteModels.put(m); }
          case 'facturas':
            final m = await isar.facturaModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.facturaModels.put(m); }
          case 'devoluciones':
            final m = await isar.devolucionModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.devolucionModels.put(m); }
          case 'proveedores':
            final m = await isar.proveedorModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.proveedorModels.put(m); }
          case 'historial_precios':
            final m = await isar.historialPreciosModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.historialPreciosModels.put(m); }
          case 'productos':
            final m = await isar.productoModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.productoModels.put(m); }
          case 'inventario_camion':
            final m = await isar.inventarioCamionModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.inventarioCamionModels.put(m); }
          case 'inventario_bodega':
            final m = await isar.inventarioBodegaModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.inventarioBodegaModels.put(m); }
          case 'recepciones':
            final m = await isar.recepcionModels.filter().codigoEqualTo(codigo).findFirst();
            if (m != null) { m.isSynced = true; await isar.recepcionModels.put(m); }
          case 'detalles_recepcion':
          case 'detalles_factura':
            break;
        }
      });
    } catch (e) {
      debugPrint('SyncService: failed to mark local as synced for ${item.table}: $e');
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
      case 'inventario_camion':
        await client.from('inventario_camion').delete().eq('codigo', id);
        break;
      case 'inventario_bodega':
        await client.from('inventario_bodega').delete().eq('codigo', id);
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
      _lastError = 'pullAll: $e';
      debugPrint('SyncService: pullAll failed: $e');
      _isSyncing = false;
      _notifyResult(pushed: 0, failed: 1);
    }
  }

  Future<void> _pullTable(dynamic client, String table) async {
    try {
      final response = await client.from(table).select();
      if (response == null) return;
      final rows = response as List<dynamic>;
      if (rows.isEmpty) return;
      final isar = _isar;
      if (isar == null) return;

      await isar.writeTxn(() async {
        switch (table) {
          case 'clientes':
            await _pullClientes(isar, rows);
            break;
          case 'facturas':
            await _pullFacturas(isar, rows);
            break;
          case 'devoluciones':
            await _pullDevoluciones(isar, rows);
            break;
          case 'proveedores':
            await _pullProveedores(isar, rows);
            break;
          case 'historial_precios':
            await _pullHistorialPrecios(isar, rows);
            break;
          case 'productos':
            await _pullProductos(isar, rows);
            break;
          case 'inventario_camion':
            await _pullInventarioCamion(isar, rows);
            break;
          case 'inventario_bodega':
            await _pullInventarioBodega(isar, rows);
            break;
          case 'recepciones':
            await _pullRecepciones(isar, rows);
            break;
          case 'detalles_recepcion':
            break;
        }
      });
    } catch (e) {
      debugPrint('SyncService: pull $table failed: $e');
    }
  }

  String? _extractCodigo(SyncQueueItem item) {
    try {
      final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
      return record['codigo']?.toString();
    } catch (_) {
      return null;
    }
  }

  // ---- Pull helpers per table ----

  Future<void> _pullClientes(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.clienteModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = ClienteModel()
          ..codigo = codigo
          ..nombre = (map['nombre'] ?? '').toString()
          ..identificadorFiscal = (map['identificador_fiscal'] ?? '').toString()
          ..direccion = (map['direccion'] ?? '').toString()
          ..latitud = (map['latitud'] as num?)?.toDouble()
          ..longitud = (map['longitud'] as num?)?.toDouble()
          ..limiteCredito = (map['limite_credito'] as num?)?.toDouble() ?? 0.0
          ..saldoPendiente = (map['saldo_pendiente'] as num?)?.toDouble() ?? 0.0
          ..estadoCuenta = (map['estado_cuenta'] ?? 'activo').toString()
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.clienteModels.put(model);
      }
    }
  }

  Future<void> _pullFacturas(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.facturaModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final detallesRaw = map['detalles'];
        List<DetalleFacturaModel>? detalles;
        if (detallesRaw is List) {
          detalles = detallesRaw.map((d) => DetalleFacturaModel()
            ..productoId = (d['producto_id'] ?? '').toString()
            ..cantidad = (d['cantidad'] as num?)?.toInt() ?? 0
            ..precioUnitario = (d['precio_unitario'] as num?)?.toDouble() ?? 0.0
            ..subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0.0
          ).toList();
        }
        final model = FacturaModel()
          ..codigo = codigo
          ..clienteId = (map['cliente_id'] ?? '').toString()
          ..vendedorId = (map['vendedor_id'] ?? '').toString()
          ..fecha = _parseDateTime(map['fecha']) ?? DateTime.now()
          ..total = (map['total'] as num?)?.toDouble() ?? 0.0
          ..tipoPago = (map['tipo_pago'] ?? 'contado').toString()
          ..latitudVenta = (map['latitud_venta'] as num?)?.toDouble()
          ..longitudVenta = (map['longitud_venta'] as num?)?.toDouble()
          ..detalles = detalles
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.facturaModels.put(model);
      }
    }
  }

  Future<void> _pullDevoluciones(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.devolucionModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = DevolucionModel()
          ..codigo = codigo
          ..facturaId = (map['factura_id'] ?? '').toString()
          ..productoId = (map['producto_id'] ?? '').toString()
          ..cantidad = (map['cantidad'] as num?)?.toInt() ?? 0
          ..canastaDestino = (map['canasta_destino'] ?? '').toString()
          ..fechaDevolucion = _parseDateTime(map['fecha_devolucion']) ?? DateTime.now()
          ..motivo = (map['motivo'] ?? '').toString()
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.devolucionModels.put(model);
      }
    }
  }

  Future<void> _pullProveedores(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.proveedorModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = ProveedorModel()
          ..codigo = codigo
          ..nombre = (map['nombre'] ?? '').toString()
          ..nit = (map['nit'] ?? '').toString()
          ..telefono = (map['telefono'] ?? '').toString()
          ..direccion = (map['direccion'] ?? '').toString()
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.proveedorModels.put(model);
      }
    }
  }

  Future<void> _pullHistorialPrecios(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.historialPreciosModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = HistorialPreciosModel()
          ..codigo = codigo
          ..productoId = (map['producto_id'] ?? '').toString()
          ..proveedorId = (map['proveedor_id'] ?? '').toString()
          ..precioCompra = (map['precio_compra'] as num?)?.toDouble() ?? 0.0
          ..fechaRegistro = _parseDateTime(map['fecha_registro']) ?? DateTime.now()
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.historialPreciosModels.put(model);
      }
    }
  }

  Future<void> _pullProductos(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.productoModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = ProductoModel()
          ..codigo = codigo
          ..nombre = (map['nombre'] ?? '').toString()
          ..precio = (map['precio'] as num?)?.toDouble() ?? 0.0
          ..imagenUrl = map['imagen_url']?.toString()
          ..isOriginal = map['is_original'] == true
          ..motosCompatibles = (map['motos_compatibles'] ?? '').toString()
          ..stockMinimo = (map['stock_minimo'] as num?)?.toInt() ?? 0
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.productoModels.put(model);
      }
    }
  }

  Future<void> _pullInventarioCamion(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.inventarioCamionModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = InventarioCamionModel()
          ..codigo = codigo
          ..productoId = (map['producto_id'] ?? '').toString()
          ..canastaId = (map['canasta_id'] ?? '').toString()
          ..cantidad = (map['cantidad'] as num?)?.toInt() ?? 0
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.inventarioCamionModels.put(model);
      }
    }
  }

  Future<void> _pullInventarioBodega(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.inventarioBodegaModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final model = InventarioBodegaModel()
          ..codigo = codigo
          ..productoId = (map['producto_id'] ?? '').toString()
          ..cantidad = (map['cantidad'] as num?)?.toInt() ?? 0
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.inventarioBodegaModels.put(model);
      }
    }
  }

  Future<void> _pullRecepciones(Isar isar, List<dynamic> rows) async {
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final codigo = map['codigo']?.toString();
      if (codigo == null) continue;
      final remoteUpdatedAt = _parseTimestamp(map['updated_at']);
      final local = await isar.recepcionModels.filter().codigoEqualTo(codigo).findFirst();
      final localJson = local?.toJson();
      final localUpdatedAt = _parseTimestamp(localJson?['updated_at']);
      if (local == null || (remoteUpdatedAt != null && localUpdatedAt != null && remoteUpdatedAt.isAfter(localUpdatedAt))) {
        final detallesRaw = map['detalles'];
        List<DetalleRecepcionModel>? detalles;
        if (detallesRaw is List) {
          detalles = detallesRaw.map((d) => DetalleRecepcionModel()
            ..productoId = (d['producto_id'] ?? '').toString()
            ..cantidad = (d['cantidad'] as num?)?.toInt() ?? 0
            ..precioUnitario = (d['precio_unitario'] as num?)?.toDouble() ?? 0.0
            ..destino = (d['destino'] ?? 'camion').toString()
            ..cantidadCamion = (d['cantidad_camion'] as num?)?.toInt()
            ..cantidadBodega = (d['cantidad_bodega'] as num?)?.toInt()
          ).toList();
        }
        final model = RecepcionModel()
          ..codigo = codigo
          ..proveedorId = (map['proveedor_id'] ?? '').toString()
          ..fecha = _parseDateTime(map['fecha']) ?? DateTime.now()
          ..nroRemito = map['nro_remito']?.toString()
          ..observaciones = map['observaciones']?.toString()
          ..detalles = detalles
          ..isSynced = true;
        if (local != null) model.id = local.id;
        await isar.recepcionModels.put(model);
      }
    }
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
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
    await _tryPushAll();
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