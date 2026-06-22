import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/sync_log_entry.dart';
import 'package:super_motos/core/services/sync_log_service_stub.dart';

class SyncLogServiceWeb extends SyncLogServiceBase {
  SyncLogServiceWeb._();
  static final SyncLogServiceWeb instance = SyncLogServiceWeb._();

  static const String _prefsKey = 'sync_logs';
  static const int _maxRetries = 5;
  static const int _maxLogs = 500;

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<SyncLogEntry>> _getAllLogs() async {
    if (_prefs == null) return [];
    try {
      final raw = _prefs!.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => SyncLogEntry.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('SyncLogServiceWeb: failed to get logs: $e');
      return [];
    }
  }

  Future<void> _saveAllLogs(List<SyncLogEntry> logs) async {
    if (_prefs == null) return;
    try {
      final raw = jsonEncode(logs.map((e) => e.toMap()).toList());
      await _prefs!.setString(_prefsKey, raw);
    } catch (e) {
      debugPrint('SyncLogServiceWeb: failed to save logs: $e');
    }
  }

  @override
  Future<int> logSyncEvent(SyncLogEntry entry) async {
    final logs = await _getAllLogs();
    final newId = logs.isNotEmpty ? (logs.map((l) => l.id ?? 0).reduce((a, b) => a > b ? a : b) + 1) : 1;
    final newEntry = SyncLogEntry(
      id: newId,
      timestamp: entry.timestamp,
      table: entry.table,
      operation: entry.operation,
      recordId: entry.recordId,
      status: entry.status,
      errorMessage: entry.errorMessage,
      retryCount: entry.retryCount,
    );
    logs.insert(0, newEntry);
    await _pruneOldLogs(logs);
    await _saveAllLogs(logs);
    return newId;
  }

  @override
  Future<void> updateLogStatus(int id, SyncLogStatus status, {String? errorMessage, int? retryCount}) async {
    final logs = await _getAllLogs();
    final index = logs.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final old = logs[index];
    logs[index] = SyncLogEntry(
      id: old.id,
      timestamp: old.timestamp,
      table: old.table,
      operation: old.operation,
      recordId: old.recordId,
      status: status,
      errorMessage: errorMessage ?? old.errorMessage,
      retryCount: retryCount ?? old.retryCount,
    );
    await _saveAllLogs(logs);
  }

  @override
  Future<List<SyncLogEntry>> getLogs({
    String? table,
    SyncLogStatus? status,
    int limit = 100,
  }) async {
    var logs = await _getAllLogs();
    if (table != null) {
      logs = logs.where((l) => l.table == table).toList();
    }
    if (status != null) {
      logs = logs.where((l) => l.status == status).toList();
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  @override
  Future<int> getPendingCount() async {
    final logs = await _getAllLogs();
    return logs.where((l) =>
      l.status == SyncLogStatus.pending ||
      l.status == SyncLogStatus.retrying ||
      l.status == SyncLogStatus.failed
    ).length;
  }

  @override
  Future<void> deleteLog(int id) async {
    final logs = await _getAllLogs();
    logs.removeWhere((l) => l.id == id);
    await _saveAllLogs(logs);
  }

  @override
  Future<void> clearOldLogs({int maxAgeDays = 7}) async {
    final logs = await _getAllLogs();
    final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays));
    final filtered = logs.where((l) => l.timestamp.isAfter(cutoff)).toList();
    await _saveAllLogs(filtered);
  }

  Future<void> _pruneOldLogs(List<SyncLogEntry> logs) async {
    if (logs.length > _maxLogs) {
      logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      logs.removeRange(0, logs.length - _maxLogs);
    }
  }

  @override
  static int get maxRetries => _maxRetries;

  @override
  Future<void> close() async {
    _prefs = null;
  }
}

SyncLogServiceBase createSyncLogService() => SyncLogServiceWeb.instance;
