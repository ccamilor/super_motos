import 'package:isar/isar.dart';
import 'package:super_motos/core/database/isar_service.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';

class SyncService {
  final IsarService _isarService;

  SyncService(this._isarService);

  Future<Map<String, List<dynamic>>> getUnsyncedData() async {
    final isar = _isarService.isar;
    final facturas = await isar.facturaModels.filter().isSyncedEqualTo(false).findAll();
    final devoluciones = await isar.devolucionModels.filter().isSyncedEqualTo(false).findAll();

    return {
      'facturas': facturas,
      'devoluciones': devoluciones,
    };
  }

  Future<void> synchronizePendingData() async {
    final unsynced = await getUnsyncedData();
    final facturas = unsynced['facturas'] as List<FacturaModel>;
    final devoluciones = unsynced['devoluciones'] as List<DevolucionModel>;

    if (facturas.isEmpty && devoluciones.isEmpty) {
      print("No hay datos pendientes de sincronización.");
      return;
    }

    final isar = _isarService.isar;

    await isar.writeTxn(() async {
      for (final factura in facturas) {
        print("Sincronizando Factura ID: ${factura.numeroFactura} con el servidor central");
        factura.isSynced = true;
        await isar.facturaModels.put(factura);
      }

      for (final devolucion in devoluciones) {
        print("Sincronizando Devolución ID: ${devolucion.id} con el servidor central");
        devolucion.isSynced = true;
        await isar.devolucionModels.put(devolucion);
      }
    });
  }
}
