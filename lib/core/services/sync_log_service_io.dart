import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_motos/core/services/sync_log_entry.dart';
import 'package:super_motos/core/services/sync_log_service_stub.dart';

class SyncLogServiceIO extends SyncLogServiceBase {
  SyncLogServiceIO._();
  static final SyncLogServiceIO instance = SyncLogServiceIO._();

  static const String _dbName = 'sync_logs.db';
  static const String _tableName = 'sync_logs';
  static const int _maxRetries = 5;
  static const int _maxLogs = 500;

  Database? _database;

  @override
  Future<void> init() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp TEXT NOT NULL,
              table_name TEXT NOT NULL,
              operation TEXT NOT NULL,
              record_id TEXT NOT NULL,
              status TEXT NOT NULL,
              error_message TEXT,
              retry_count INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to init database: $e');
    }
  }

  @override
  Future<int> logSyncEvent(SyncLogEntry entry) async {
    final db = _database;
    if (db == null) return -1;
    try {
      final id = await db.insert(_tableName, entry.toMap());
      await _pruneOldLogs();
      return id;
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to log event: $e');
      return -1;
    }
  }

  @override
  Future<void> updateLogStatus(int id, SyncLogStatus status, {String? errorMessage, int? retryCount}) async {
    final db = _database;
    if (db == null) return;
    try {
      await db.update(
        _tableName,
        {
          'status': status.name,
          if (errorMessage != null) 'error_message': errorMessage,
          if (retryCount != null) 'retry_count': retryCount,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to update log: $e');
    }
  }

  @override
  Future<List<SyncLogEntry>> getLogs({
    String? table,
    SyncLogStatus? status,
    int limit = 100,
  }) async {
    final db = _database;
    if (db == null) return [];
    try {
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (table != null) {
        whereClauses.add('table_name = ?');
        whereArgs.add(table);
      }
      if (status != null) {
        whereClauses.add('status = ?');
        whereArgs.add(status.name);
      }

      final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final maps = await db.query(
        _tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return maps.map((m) => SyncLogEntry.fromMap(m)).toList();
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to get logs: $e');
      return [];
    }
  }

  @override
  Future<int> getPendingCount() async {
    final db = _database;
    if (db == null) return 0;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE status IN (?, ?, ?)',
        [SyncLogStatus.pending.name, SyncLogStatus.retrying.name, SyncLogStatus.failed.name],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to get pending count: $e');
      return 0;
    }
  }

  @override
  Future<void> deleteLog(int id) async {
    final db = _database;
    if (db == null) return;
    try {
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to delete log: $e');
    }
  }

  @override
  Future<void> clearOldLogs({int maxAgeDays = 7}) async {
    final db = _database;
    if (db == null) return;
    try {
      final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays)).toIso8601String();
      await db.delete(_tableName, where: 'timestamp < ?', whereArgs: [cutoff]);
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to clear old logs: $e');
    }
  }

  Future<void> _pruneOldLogs() async {
    final db = _database;
    if (db == null) return;
    try {
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      final total = Sqflite.firstIntValue(count) ?? 0;
      if (total > _maxLogs) {
        await db.execute('''
          DELETE FROM $_tableName WHERE id IN (
            SELECT id FROM $_tableName ORDER BY timestamp ASC LIMIT ?
          )
        ''', [total - _maxLogs]);
      }
    } catch (e) {
      debugPrint('SyncLogServiceIO: failed to prune logs: $e');
    }
  }

  static int get maxRetries => _maxRetries;

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

SyncLogServiceBase createSyncLogService() => SyncLogServiceIO.instance;
