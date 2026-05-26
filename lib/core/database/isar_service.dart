import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/customers/data/models/cliente_model.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/auth/data/models/usuario_model.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';

class IsarService {
  late Isar isar;

  Future<void> init() async {
    String directory = '';
    if (!kIsWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      directory = appDir.path;
    }

    isar = await Isar.open(
      [
        ProductoModelSchema,
        InventarioBodegaModelSchema,
        InventarioCamionModelSchema,
        ClienteModelSchema,
        FacturaModelSchema,
        UsuarioModelSchema,
        ProveedorModelSchema,
        HistorialPreciosModelSchema,
        DevolucionModelSchema,
      ],
      directory: directory,
    );
  }
}
