import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';

class InventorySnapshot {
  final List<ProductoModel> productos;
  final List<InventarioCamionModel> camion;
  final List<InventarioBodegaModel> bodega;

  const InventorySnapshot({
    required this.productos,
    required this.camion,
    required this.bodega,
  });

  static const empty = InventorySnapshot(
    productos: [],
    camion: [],
    bodega: [],
  );
}
