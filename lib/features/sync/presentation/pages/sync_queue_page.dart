import 'package:flutter/material.dart';
import 'package:super_motos/core/services/sync_log_service.dart';
import 'package:super_motos/core/services/sync_service.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> {
  List<SyncLogEntry> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await createSyncLogService().getLogs(limit: 100);
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryItem(SyncLogEntry log) async {
    await createSyncLogService().updateLogStatus(
      log.id ?? -1,
      SyncLogStatus.pending,
      retryCount: 0,
    );
    await SyncService.instance.forcePushAll();
    await _loadLogs();
  }

  Future<void> _deleteItem(SyncLogEntry log) async {
    await createSyncLogService().deleteLog(log.id ?? -1);
    await _loadLogs();
  }

  Future<void> _clearOldLogs() async {
    await createSyncLogService().clearOldLogs(maxAgeDays: 1);
    await _loadLogs();
  }

  Map<String, List<SyncLogEntry>> _groupLogsByTable() {
    final grouped = <String, List<SyncLogEntry>>{};
    for (final log in _logs) {
      grouped.putIfAbsent(log.table, () => []);
      grouped[log.table]!.add(log);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupedLogs = _groupLogsByTable();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cola de Sincronización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearOldLogs,
            tooltip: 'Limpiar logs antiguos',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_done,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Todo sincronizado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay elementos pendientes en la cola',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedLogs.length,
                    itemBuilder: (context, index) {
                      final table = groupedLogs.keys.elementAt(index);
                      final logs = groupedLogs[table]!;
                      return _buildTableGroup(table, logs, colorScheme);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await SyncService.instance.forcePushAll();
          await _loadLogs();
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sincronizar ahora'),
      ),
    );
  }

  Widget _buildTableGroup(String table, List<SyncLogEntry> logs, ColorScheme colorScheme) {
    final pendingCount = logs.where((l) => 
      l.status == SyncLogStatus.pending || 
      l.status == SyncLogStatus.retrying || 
      l.status == SyncLogStatus.failed
    ).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(
          _getTableIcon(table),
          color: colorScheme.primary,
        ),
        title: Text(
          _formatTableName(table),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$pendingCount pendientes'),
        children: logs.map((log) => _buildLogItem(log, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildLogItem(SyncLogEntry log, ColorScheme colorScheme) {
    return ListTile(
      leading: _buildStatusIcon(log.status, colorScheme),
      title: Text(
        log.recordId,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${log.operation} • ${_formatTimestamp(log.timestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.error,
              ),
            ),
          if (log.retryCount > 0)
            Text(
              'Reintentos: ${log.retryCount}/5',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'retry') {
            await _retryItem(log);
          } else if (value == 'delete') {
            await _deleteItem(log);
          }
        },
        itemBuilder: (context) => [
          if (log.status == SyncLogStatus.failed || log.status == SyncLogStatus.permanentFailed)
            const PopupMenuItem(
              value: 'retry',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Reintentar'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SyncLogStatus status, ColorScheme colorScheme) {
    switch (status) {
      case SyncLogStatus.pending:
        return Icon(Icons.pending, color: Colors.orange);
      case SyncLogStatus.retrying:
        return Icon(Icons.autorenew, color: Colors.orange);
      case SyncLogStatus.failed:
        return Icon(Icons.error, color: Colors.red);
      case SyncLogStatus.permanentFailed:
        return Icon(Icons.error_outline, color: Colors.red.shade900);
      case SyncLogStatus.synced:
        return Icon(Icons.check_circle, color: Colors.green);
    }
  }

  IconData _getTableIcon(String table) {
    switch (table) {
      case 'productos':
        return Icons.inventory_2;
      case 'clientes':
        return Icons.people;
      case 'facturas':
        return Icons.receipt;
      case 'devoluciones':
        return Icons.assignment_return;
      case 'proveedores':
        return Icons.local_shipping;
      case 'historial_precios':
        return Icons.history;
      case 'inventario_camion':
        return Icons.local_shipping;
      case 'inventario_bodega':
        return Icons.warehouse;
      case 'recepciones':
        return Icons.inventory;
      case 'detalles_recepcion':
        return Icons.list_alt;
      default:
        return Icons.data_usage;
    }
  }

  String _formatTableName(String table) {
    switch (table) {
      case 'productos':
        return 'Productos';
      case 'clientes':
        return 'Clientes';
      case 'facturas':
        return 'Facturas';
      case 'devoluciones':
        return 'Devoluciones';
      case 'proveedores':
        return 'Proveedores';
      case 'historial_precios':
        return 'Historial de Precios';
      case 'inventario_camion':
        return 'Inventario Camión';
      case 'inventario_bodega':
        return 'Inventario Bodega';
      case 'recepciones':
        return 'Recepciones';
      case 'detalles_recepcion':
        return 'Detalles de Recepción';
      default:
        return table;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
