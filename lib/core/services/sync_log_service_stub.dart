import 'package:super_motos/core/services/sync_log_entry.dart';

abstract class SyncLogServiceBase {
  Future<void> init();
  Future<int> logSyncEvent(SyncLogEntry entry);
  Future<void> updateLogStatus(int id, SyncLogStatus status, {String? errorMessage, int? retryCount});
  Future<List<SyncLogEntry>> getLogs({String? table, SyncLogStatus? status, int limit = 100});
  Future<int> getPendingCount();
  Future<void> deleteLog(int id);
  Future<void> clearOldLogs({int maxAgeDays = 7});
  static int get maxRetries => 5;
  Future<void> close();
}

SyncLogServiceBase createSyncLogService() => throw UnsupportedError('SyncLogService not implemented for this platform');
