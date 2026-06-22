import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:super_motos/core/services/sync_log_service.dart';
import 'package:super_motos/core/services/sync_queue_item.dart';
import 'package:super_motos/core/services/sync_service.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> {
  List<SyncQueueItem> _pendingItems = [];
  List<SyncLogEntry> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _pendingItems = SyncService.instance.pendingItems
        .where((item) => !item.synced)
        .toList();

    final logs = await createSyncLogService().getLogs(limit: 100);

    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryLogItem(SyncLogEntry log) async {
    await createSyncLogService().updateLogStatus(
      log.id ?? -1,
      SyncLogStatus.pending,
      retryCount: 0,
    );
    final record = {'codigo': log.recordId};
    SyncService.instance.enqueue(
      log.table,
      SyncOperation.insert,
      jsonEncode(record),
    );
    await SyncService.instance.forcePushAll();
    await _loadData();
  }

  Future<void> _retryQueueItem(SyncQueueItem item) async {
    item.retryCount = 0;
    await SyncService.instance.forcePushAll();
    await _loadData();
  }

  Future<void> _deleteLogItem(SyncLogEntry log) async {
    await createSyncLogService().deleteLog(log.id ?? -1);
    await _loadData();
  }

  Future<void> _clearOldLogs() async {
    await createSyncLogService().clearOldLogs(maxAgeDays: 1);
    await _loadData();
  }

  String _getRecordId(SyncQueueItem item) {
    try {
      final record = jsonDecode(item.recordJson) as Map<String, dynamic>;
      return record['codigo']?.toString() ?? record['id']?.toString() ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  Map<String, List<SyncQueueItem>> _groupPendingByTable() {
    final grouped = <String, List<SyncQueueItem>>{};
    for (final item in _pendingItems) {
      grouped.putIfAbsent(item.table, () => []);
      grouped[item.table]!.add(item);
    }
    return grouped;
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
    final groupedPending = _groupPendingByTable();

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
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (SyncService.instance.lastError != null)
                    _buildErrorBanner(colorScheme),
                  _buildSectionHeader(
                    'Pendientes de sincronizar',
                    _pendingItems.length,
                    Icons.cloud_upload,
                    colorScheme,
                    pending: true,
                  ),
                  if (_pendingItems.isEmpty)
                    _buildEmptyState(
                      'No hay elementos pendientes',
                      Icons.cloud_done,
                      colorScheme.primary,
                    )
                  else
                    ...groupedPending.entries.map(
                      (entry) => _buildPendingGroup(entry.key, entry.value, colorScheme),
                    ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    'Historial de sincronización',
                    _logs.length,
                    Icons.history,
                    colorScheme,
                    pending: false,
                  ),
                  if (_logs.isEmpty)
                    _buildEmptyState(
                      'No hay registros de sincronización',
                      Icons.history_toggle_off,
                      colorScheme.onSurface.withValues(alpha: 0.6),
                    )
                  else
                    ..._groupLogsByTable().entries.map(
                      (entry) => _buildLogGroup(entry.key, entry.value, colorScheme),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await SyncService.instance.forcePushAll();
          await _loadData();
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sincronizar ahora'),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme) {
    final error = SyncService.instance.lastError ?? 'Error desconocido';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, ColorScheme colorScheme, {required bool pending}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: pending ? Colors.orange : colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (pending && count > 0)
                  ? Colors.orange.withValues(alpha: 0.2)
                  : colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: (pending && count > 0) ? Colors.orange : colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingGroup(String table, List<SyncQueueItem> items, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(_getTableIcon(table), color: Colors.orange),
        title: Text(
          _formatTableName(table),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${items.length} pendiente(s)'),
        children: items.map((item) => _buildPendingItem(item, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildPendingItem(SyncQueueItem item, ColorScheme colorScheme) {
    final recordId = _getRecordId(item);
    return ListTile(
      leading: Icon(
        item.retryCount > 0 ? Icons.autorenew : Icons.hourglass_empty,
        color: Colors.orange,
      ),
      title: Text(recordId, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.operation.name} • ${_formatTimestamp(item.createdAt)}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          if (item.retryCount > 0)
            Text(
              'Reintentos: ${item.retryCount}/5',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'retry') {
            await _retryQueueItem(item);
          }
        },
        itemBuilder: (context) => [
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
        ],
      ),
    );
  }

  Widget _buildLogGroup(String table, List<SyncLogEntry> logs, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(_getTableIcon(table), color: colorScheme.primary),
        title: Text(
          _formatTableName(table),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${logs.length} registros'),
        children: logs.map((log) => _buildLogItem(log, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildLogItem(SyncLogEntry log, ColorScheme colorScheme) {
    return ListTile(
      leading: _buildStatusIcon(log.status, colorScheme),
      title: Text(log.recordId, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${log.operation} • ${_formatTimestamp(log.timestamp)}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          if (log.errorMessage != null)
            Text(
              log.errorMessage!,
              style: TextStyle(fontSize: 12, color: colorScheme.error),
            ),
          if (log.retryCount > 0)
            Text(
              'Reintentos: ${log.retryCount}/5',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'retry') {
            await _retryLogItem(log);
          } else if (value == 'delete') {
            await _deleteLogItem(log);
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
        return const Icon(Icons.pending, color: Colors.orange);
      case SyncLogStatus.retrying:
        return const Icon(Icons.autorenew, color: Colors.orange);
      case SyncLogStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case SyncLogStatus.permanentFailed:
        return Icon(Icons.error_outline, color: Colors.red.shade900);
      case SyncLogStatus.synced:
        return const Icon(Icons.check_circle, color: Colors.green);
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
