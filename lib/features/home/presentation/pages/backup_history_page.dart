import 'package:flutter/material.dart';
import 'package:super_motos/core/services/supabase_service.dart';

class BackupHistoryPage extends StatefulWidget {
  const BackupHistoryPage({super.key});

  @override
  State<BackupHistoryPage> createState() => _BackupHistoryPageState();
}

class _BackupHistoryPageState extends State<BackupHistoryPage> {
  List<_BackupFile> _backups = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = SupabaseService.instance.client;
      final files = await client.storage.from('backups').list(path: 'inventory');

      final backups = files.map((f) {
        final name = f.name;
        final size = f.metadata?['size'] as int? ?? 0;
        final createdAt = f.createdAt != null
            ? DateTime.tryParse(f.createdAt!)
            : _parseTimestampFromName(name);
        return _BackupFile(
          name: name,
          size: size,
          createdAt: createdAt ?? DateTime.now(),
        );
      }).toList();

      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _backups = backups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  DateTime? _parseTimestampFromName(String name) {
    final match = RegExp(r'_(\d{13})\.csv$').firstMatch(name);
    if (match != null) {
      final ms = int.tryParse(match.group(1)!);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }

  Future<void> _deleteBackup(_BackupFile backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar backup'),
        content: Text('Estas seguro de eliminar "${backup.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final client = SupabaseService.instance.client;
      await client.storage.from('backups').remove(['inventory/${backup.name}']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup eliminado'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Backups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackups,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar backups',
                        style: TextStyle(color: colorScheme.error, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBackups,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _backups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 64,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay backups disponibles',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los backups se guardan automaticamente cada 24h',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _backups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final backup = _backups[index];
                        return _buildBackupItem(backup, colorScheme);
                      },
                    ),
    );
  }

  Widget _buildBackupItem(_BackupFile backup, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.cloud_outlined,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          _formatDate(backup.createdAt),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          _formatSize(backup.size),
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          onPressed: () => _deleteBackup(backup),
          tooltip: 'Eliminar',
        ),
      ),
    );
  }
}

class _BackupFile {
  final String name;
  final int size;
  final DateTime createdAt;

  _BackupFile({
    required this.name,
    required this.size,
    required this.createdAt,
  });
}
