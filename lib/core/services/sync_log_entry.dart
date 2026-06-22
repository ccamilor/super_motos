enum SyncLogStatus { pending, retrying, failed, permanentFailed, synced }

class SyncLogEntry {
  final int? id;
  final DateTime timestamp;
  final String table;
  final String operation;
  final String recordId;
  final SyncLogStatus status;
  final String? errorMessage;
  final int retryCount;

  SyncLogEntry({
    this.id,
    required this.timestamp,
    required this.table,
    required this.operation,
    required this.recordId,
    required this.status,
    this.errorMessage,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.toIso8601String(),
      'table': table,
      'operation': operation,
      'recordId': recordId,
      'status': status.name,
      'errorMessage': errorMessage,
      'retryCount': retryCount,
    };
  }

  static SyncLogEntry fromMap(Map<String, dynamic> map) {
    return SyncLogEntry(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      table: map['table'] as String,
      operation: map['operation'] as String,
      recordId: map['recordId'] as String,
      status: SyncLogStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncLogStatus.pending,
      ),
      errorMessage: map['errorMessage'] as String?,
      retryCount: (map['retryCount'] as int?) ?? 0,
    );
  }
}
