import 'package:flutter/material.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/sync/presentation/pages/sync_queue_page.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool isSynced;
  final DateTime? lastSyncedAt;
  final bool compact;

  const SyncStatusBadge({
    super.key,
    required this.isSynced,
    this.lastSyncedAt,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSynced) {
      return _buildBadge(
        context,
        icon: Icons.cloud_done_rounded,
        label: 'Sincronizado',
        color: colorScheme.primary,
        compact: compact,
      );
    }

    return _buildBadge(
      context,
      icon: Icons.cloud_off_rounded,
      label: 'Pendiente',
      color: colorScheme.secondary,
      compact: compact,
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool compact,
  }) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: 14, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (lastSyncedAt != null) ...[
            const SizedBox(width: 4),
            Text(
              _formatTime(lastSyncedAt!),
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class SyncIndicator extends StatelessWidget {
  final int pendingCount;

  const SyncIndicator({
    super.key,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (pendingCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Todo sincronizado',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload_rounded, size: 16, color: colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            '$pendingCount pendiente${pendingCount == 1 ? '' : 's'}',
            style: TextStyle(
              color: colorScheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncStateIndicator extends StatefulWidget {
  const SyncStateIndicator({super.key});

  @override
  State<SyncStateIndicator> createState() => _SyncStateIndicatorState();
}

class _SyncStateIndicatorState extends State<SyncStateIndicator> {
  @override
  void initState() {
    super.initState();
    SyncService.instance.syncResultNotifier.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    SyncService.instance.syncResultNotifier.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final result = SyncService.instance.syncResultNotifier.value;
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color color;
    String label;

    switch (result.status) {
      case SyncStatus.syncing:
        icon = Icons.cloud_sync_rounded;
        color = Colors.orange;
        label = 'Sincronizando...';
      case SyncStatus.synced:
        if (result.totalPending > 0) {
          icon = Icons.cloud_upload_rounded;
          color = colorScheme.secondary;
          label = '${result.totalPending} pendiente${result.totalPending == 1 ? '' : 's'}';
        } else {
          icon = Icons.cloud_done_rounded;
          color = colorScheme.primary;
          label = 'Sincronizado';
        }
      case SyncStatus.error:
        icon = Icons.cloud_off_rounded;
        color = colorScheme.error;
        label = 'Error de sync';
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SyncQueuePage()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.status == SyncStatus.syncing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
