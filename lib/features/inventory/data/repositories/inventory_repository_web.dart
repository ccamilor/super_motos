import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_seed_data.dart';
import '../../presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) '../../presentation/pages/web_storage_web.dart';

const String _csvStorageKey = 'super_motos_csv_data';

class WebInventoryRepository implements InventoryRepository {
  static List<ProductoModel> _productos = [];
  static List<InventarioCamionModel> _camion = [];
  static List<InventarioBodegaModel> _bodega = [];

  final InventoryCsvParser _parser = const InventoryCsvParser();

  @override
  Future<InventorySnapshot> loadInventory() async {
    if (_productos.isEmpty) {
      final savedData = getWebStorage().getItem(_csvStorageKey);
      if (savedData != null && savedData.isNotEmpty) {
        final entries = _parser.parse(savedData);
        if (entries.isNotEmpty) {
          _applyEntries(entries);
          return _snapshot();
        }
      }

      _applyEntries(InventorySeedData.demoEntries);
    }

    return _snapshot();
  }

  @override
  Future<InventorySnapshot> importCsv(String csvContent) async {
    final entries = _parser.parse(csvContent);
    if (entries.isEmpty) {
      throw FormatException('El CSV está vacío o no contiene filas válidas.');
    }

    getWebStorage().setItem(_csvStorageKey, csvContent);
    _applyEntries(entries);
    return _snapshot();
  }

  void _applyEntries(Iterable<dynamic> entries) {
    _productos = [];
    _camion = [];
    _bodega = [];

    for (final entry in entries) {
      _productos.add(entry.toProductoModel());
      _camion.add(entry.toCamionModel());
      _bodega.add(entry.toBodegaModel());
    }
  }

  InventorySnapshot _snapshot() {
    return InventorySnapshot(
      productos: List<ProductoModel>.from(_productos),
      camion: List<InventarioCamionModel>.from(_camion),
      bodega: List<InventarioBodegaModel>.from(_bodega),
    );
  }

  @override
  Future<void> decrementCamionStock(int productoId, int cantidad) async {
    final idx = _camion.indexWhere((c) => c.productoId == productoId);
    if (idx == -1) {
      throw StateError('No hay registro de stock en el camion para producto $productoId');
    }
    final model = _camion[idx];
    if (model.cantidad < cantidad) {
      throw StateError(
        'Stock insuficiente en el camion para producto $productoId (disponible: ${model.cantidad}, requerido: $cantidad)',
      );
    }
    final updated = InventarioCamionModel()
      ..id = model.id
      ..productoId = model.productoId
      ..numeroCanasta = model.numeroCanasta
      ..cantidad = model.cantidad - cantidad;
    _camion = List<InventarioCamionModel>.from(_camion)..[idx] = updated;
  }

  @override
  Future<void> incrementCamionStock(int productoId, int cantidad) async {
    final idx = _camion.indexWhere((c) => c.productoId == productoId);
    if (idx == -1) {
      throw StateError('No hay registro de stock en el camion para producto $productoId');
    }
    final model = _camion[idx];
    final updated = InventarioCamionModel()
      ..id = model.id
      ..productoId = model.productoId
      ..numeroCanasta = model.numeroCanasta
      ..cantidad = model.cantidad + cantidad;
    _camion = List<InventarioCamionModel>.from(_camion)..[idx] = updated;
  }
}

InventoryRepository createInventoryRepository() => WebInventoryRepository();

