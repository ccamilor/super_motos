import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';

class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const String _prefsKey = 'last_backup_timestamp';
  static const String _bucketName = 'backups';
  static const Duration _backupInterval = Duration(days: 1);

  final InventoryRepository _inventoryRepo = createInventoryRepository();

  Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_prefsKey);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      debugPrint('BackupService: failed to get last backup time: $e');
      return null;
    }
  }

  Future<void> _saveLastBackupTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, time.toIso8601String());
    } catch (e) {
      debugPrint('BackupService: failed to save last backup time: $e');
    }
  }

  Future<bool> shouldBackup() async {
    final lastBackup = await getLastBackupTime();
    if (lastBackup == null) return true;
    final now = DateTime.now();
    return now.difference(lastBackup) >= _backupInterval;
  }

  Future<bool> performBackup() async {
    try {
      final csvContent = await _inventoryRepo.exportCsv();
      if (csvContent.isEmpty) {
        debugPrint('BackupService: no inventory to backup');
        return false;
      }

      final client = SupabaseService.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'inventario_backup_$timestamp.csv';
      final filePath = 'inventory/$fileName';

      final bytes = utf8.encode(csvContent);

      await client.storage.from(_bucketName).uploadBinary(
            filePath,
            bytes,
          );

      await _saveLastBackupTime(DateTime.now());
      debugPrint('BackupService: backup completed successfully to $filePath');
      return true;
    } catch (e) {
      debugPrint('BackupService: failed to perform backup: $e');
      return false;
    }
  }

  Future<bool> performBackupIfNeeded() async {
    if (!await shouldBackup()) {
      return true;
    }
    return await performBackup();
  }

  Future<List<String>> listBackups() async {
    try {
      final client = SupabaseService.instance.client;
      final files = await client.storage.from(_bucketName).list(path: 'inventory');
      return files.map((f) => f.name).toList();
    } catch (e) {
      debugPrint('BackupService: failed to list backups: $e');
      return [];
    }
  }

  Future<void> deleteOldBackups({int keepLast = 7}) async {
    try {
      final backups = await listBackups();
      if (backups.length <= keepLast) return;

      final client = SupabaseService.instance.client;
      final toDelete = backups.skip(keepLast).toList();
      
      for (final fileName in toDelete) {
        await client.storage.from(_bucketName).remove(['inventory/$fileName']);
      }
      
      debugPrint('BackupService: deleted ${toDelete.length} old backups');
    } catch (e) {
      debugPrint('BackupService: failed to delete old backups: $e');
    }
  }
}
