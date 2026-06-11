import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_seed_data.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';
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

  @override
  Future<InventorySnapshot> createProduct(InventoryEntry entry) async {
    final maxId = _productos.fold(0, (max, p) => p.id > max ? p.id : max);
    final newId = maxId + 1;

    final producto = entry.toProductoModel()..id = newId;
    final camion = entry.toCamionModel()..productoId = newId;
    final bodega = entry.toBodegaModel()..productoId = newId;

    _productos = List<ProductoModel>.from(_productos)..add(producto);
    if (entry.cantidadCamion > 0) {
      _camion = List<InventarioCamionModel>.from(_camion)..add(camion);
    }
    if (entry.cantidadBodega > 0) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)..add(bodega);
    }

    return _snapshot();
  }

  @override
  Future<InventorySnapshot> updateProduct(InventoryEntry entry) async {
    final pIdx = _productos.indexWhere((p) => p.id == entry.id);
    if (pIdx != -1) {
      final updated = _productos[pIdx]
        ..nombre = entry.nombre
        ..precio = entry.precio
        ..isOriginal = entry.isOriginal
        ..motosCompatibles = entry.motosCompatibles
        ..stockMinimo = entry.stockMinimo;
      _productos = List<ProductoModel>.from(_productos)..[pIdx] = updated;
    }

    final cIdx = _camion.indexWhere((c) => c.productoId == entry.id);
    if (cIdx != -1 && entry.cantidadCamion > 0) {
      final updated = _camion[cIdx]
        ..cantidad = entry.cantidadCamion
        ..numeroCanasta = entry.numeroCanasta;
      _camion = List<InventarioCamionModel>.from(_camion)..[cIdx] = updated;
    } else if (cIdx != -1) {
      _camion = List<InventarioCamionModel>.from(_camion)..removeAt(cIdx);
    } else if (entry.cantidadCamion > 0) {
      _camion = List<InventarioCamionModel>.from(_camion)
        ..add(entry.toCamionModel()..productoId = entry.id);
    }

    final bIdx = _bodega.indexWhere((b) => b.productoId == entry.id);
    if (bIdx != -1 && entry.cantidadBodega > 0) {
      final updated = _bodega[bIdx]
        ..cantidad = entry.cantidadBodega;
      _bodega = List<InventarioBodegaModel>.from(_bodega)..[bIdx] = updated;
    } else if (bIdx != -1) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)..removeAt(bIdx);
    } else if (entry.cantidadBodega > 0) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)
        ..add(entry.toBodegaModel()..productoId = entry.id);
    }

    return _snapshot();
  }

  @override
  Future<InventorySnapshot> deleteProduct(int id) async {
    _productos = List<ProductoModel>.from(_productos)..removeWhere((p) => p.id == id);
    _camion = List<InventarioCamionModel>.from(_camion)..removeWhere((c) => c.productoId == id);
    _bodega = List<InventarioBodegaModel>.from(_bodega)..removeWhere((b) => b.productoId == id);
    return _snapshot();
  }
}

InventoryRepository createInventoryRepository() => WebInventoryRepository();
