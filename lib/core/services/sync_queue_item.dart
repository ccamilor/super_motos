enum SyncOperation { insert, update, delete }

class SyncQueueItem {
  final int id;
  final String table;
  final SyncOperation operation;
  final String recordJson;
  final DateTime createdAt;
  bool _synced;
  int retryCount;

  SyncQueueItem({
    required this.id,
    required this.table,
    required this.operation,
    required this.recordJson,
    required this.createdAt,
    bool synced = false,
    this.retryCount = 0,
  }) : _synced = synced;

  bool get synced => _synced;
  void markSynced() => _synced = true;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table': table,
      'operation': operation.name,
      'recordJson': recordJson,
      'createdAt': createdAt.toIso8601String(),
      'synced': _synced,
      'retryCount': retryCount,
    };
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as int,
      table: json['table'] as String,
      operation: SyncOperation.values.firstWhere((e) => e.name == json['operation']),
      recordJson: json['recordJson'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool? ?? false,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  SyncQueueItem copyWith({
    int? id,
    String? table,
    SyncOperation? operation,
    String? recordJson,
    DateTime? createdAt,
    bool? synced,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      table: table ?? this.table,
      operation: operation ?? this.operation,
      recordJson: recordJson ?? this.recordJson,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this._synced,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
