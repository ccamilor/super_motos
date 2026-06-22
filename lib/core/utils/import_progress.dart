class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class ImportProgress {
  final int processed;
  final int total;
  final String? currentItem;
  final bool done;

  const ImportProgress({
    required this.processed,
    required this.total,
    this.currentItem,
    this.done = false,
  });

  double get progress => total > 0 ? processed / total : 0.0;
}
