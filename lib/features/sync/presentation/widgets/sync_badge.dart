import 'package:flutter/material.dart';
import 'package:super_motos/core/services/sync_log_service.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/sync/presentation/pages/sync_queue_page.dart';

class SyncBadge extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SyncBadge({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<SyncBadge> createState() => _SyncBadgeState();
}

class _SyncBadgeState extends State<SyncBadge> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
    SyncService.instance.syncResultNotifier.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    SyncService.instance.syncResultNotifier.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final count = await createSyncLogService().getPendingCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_pendingCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: widget.onTap ?? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SyncQueuePage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  _pendingCount > 99 ? '99+' : '$_pendingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
