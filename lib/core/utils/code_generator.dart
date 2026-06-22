import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/customers/data/models/cliente_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/recepcion/data/models/recepcion_model.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';

class CodeGenerator {
  static Future<String> next(String prefix) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'code_counter_$prefix';
      var current = prefs.getInt(key);
      if (current == null || current >= 1000) {
        current = await _maxExisting(prefix);
        await prefs.setInt(key, current);
      }
      final next = current + 1;
      await prefs.setInt(key, next);
      return '$prefix-${next.toString().padLeft(3, '0')}';
    } catch (e) {
      final codigo = '$prefix-${DateTime.now().millisecondsSinceEpoch}';
      return codigo;
    }
  }

  static Future<int> _maxExisting(String prefix) async {
    final isar = Isar.getInstance();
    if (isar == null) return 0;

    List<String> codigos;
    switch (prefix) {
      case 'CLI':
        codigos = (await isar.clienteModels.where().findAll()).map((e) => e.codigo).toList();
      case 'FAC':
        codigos = (await isar.facturaModels.where().findAll()).map((e) => e.codigo).toList();
      case 'DEV':
        codigos = (await isar.devolucionModels.where().findAll()).map((e) => e.codigo).toList();
      case 'PROV':
        codigos = (await isar.proveedorModels.where().findAll()).map((e) => e.codigo).toList();
      case 'HP':
      case 'PVHS':
        codigos = (await isar.historialPreciosModels.where().findAll()).map((e) => e.codigo).toList();
      case 'REC':
        codigos = (await isar.recepcionModels.where().findAll()).map((e) => e.codigo).toList();
      case 'PROD':
        codigos = (await isar.productoModels.where().findAll()).map((e) => e.codigo).toList();
      default:
        return 0;
    }

    int max = 0;
    for (final codigo in codigos) {
      final parts = codigo.split('-');
      if (parts.length >= 2 && parts[0] == prefix) {
        final n = int.tryParse(parts[1]);
        if (n != null && n > max && parts[1].length <= 3) max = n;
      }
    }
    return max;
  }
}
