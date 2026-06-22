import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_exporter.dart';
import 'package:super_motos/features/inventory/data/services/inventory_seed_data.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';
import 'package:super_motos/core/utils/import_progress.dart';
import '../../presentation/pages/web_storage_stub.dart'
    if (dart.library.js_interop) '../../presentation/pages/web_storage_web.dart';

const String _csvStorageKey = 'super_motos_csv_data';

class WebInventoryRepository implements InventoryRepository {
  static List<ProductoModel> _productos = [];
  static List<InventarioCamionModel> _camion = [];
  static List<InventarioBodegaModel> _bodega = [];

  final InventoryCsvParser _parser = const InventoryCsvParser();
  final InventoryCsvExporter _exporter = const InventoryCsvExporter();

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
  Future<InventorySnapshot> importCsv(String csvContent, {
    void Function(ImportProgress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final entries = _parser.parse(csvContent);
    if (entries.isEmpty) {
      throw FormatException('El CSV está vacío o no contiene filas válidas.');
    }

    const chunkSize = 500;
    final total = entries.length;
    int processed = 0;

    // Report initial progress
    onProgress?.call(ImportProgress(processed: 0, total: total));

    // Process in chunks
    for (int i = 0; i < total; i += chunkSize) {
      if (cancelToken?.isCancelled == true) {
        throw StateError('Importación cancelada por el usuario');
      }

      final chunk = entries.skip(i).take(chunkSize).toList();

      _applyEntries(chunk);

      processed += chunk.length;
      onProgress?.call(ImportProgress(
        processed: processed,
        total: total,
        currentItem: chunk.last.nombre,
      ));

      // Small delay to keep UI responsive
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // Final progress
    onProgress?.call(ImportProgress(
      processed: total,
      total: total,
      done: true,
    ));

    getWebStorage().setItem(_csvStorageKey, csvContent);
    return _snapshot();
  }

  @override
  Future<String> exportCsv() async {
    final snapshot = await loadInventory();
    final entries = <InventoryEntry>[];

    for (final producto in snapshot.productos) {
      final camion = _camion.firstWhere(
        (c) => c.productoId == producto.codigo,
        orElse: () => InventarioCamionModel()
          ..productoId = producto.codigo
          ..cantidad = 0
          ..canastaId = '0',
      );
      final bodega = _bodega.firstWhere(
        (b) => b.productoId == producto.codigo,
        orElse: () => InventarioBodegaModel()
          ..productoId = producto.codigo
          ..cantidad = 0,
      );

      entries.add(InventoryEntry(
        codigo: producto.codigo,
        nombre: producto.nombre,
        precio: producto.precio,
        isOriginal: producto.isOriginal,
        motosCompatibles: producto.motosCompatibles,
        stockMinimo: producto.stockMinimo,
        cantidadCamion: camion.cantidad,
        canastaId: camion.canastaId,
        cantidadBodega: bodega.cantidad,
      ));
    }

    return _exporter.export(entries);
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
  Future<void> decrementCamionStock(String productoId, int cantidad) async {
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
      ..codigo = model.codigo
      ..productoId = model.productoId
      ..canastaId = model.canastaId
      ..cantidad = model.cantidad - cantidad;
    _camion = List<InventarioCamionModel>.from(_camion)..[idx] = updated;
  }

  @override
  Future<void> incrementCamionStock(String productoId, int cantidad) async {
    final idx = _camion.indexWhere((c) => c.productoId == productoId);
    if (idx == -1) {
      throw StateError('No hay registro de stock en el camion para producto $productoId');
    }
    final model = _camion[idx];
    final updated = InventarioCamionModel()
      ..id = model.id
      ..codigo = model.codigo
      ..productoId = model.productoId
      ..canastaId = model.canastaId
      ..cantidad = model.cantidad + cantidad;
    _camion = List<InventarioCamionModel>.from(_camion)..[idx] = updated;
  }

  @override
  Future<InventorySnapshot> createProduct(InventoryEntry entry) async {
    final producto = entry.toProductoModel();
    final camion = entry.toCamionModel();
    final bodega = entry.toBodegaModel();

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
    final pIdx = _productos.indexWhere((p) => p.codigo == entry.codigo);
    if (pIdx != -1) {
      final updated = _productos[pIdx]
        ..nombre = entry.nombre
        ..precio = entry.precio
        ..isOriginal = entry.isOriginal
        ..motosCompatibles = entry.motosCompatibles
        ..stockMinimo = entry.stockMinimo;
      _productos = List<ProductoModel>.from(_productos)..[pIdx] = updated;
    }

    final cIdx = _camion.indexWhere((c) => c.productoId == entry.codigo);
    if (cIdx != -1 && entry.cantidadCamion > 0) {
      final updated = _camion[cIdx]
        ..cantidad = entry.cantidadCamion
        ..canastaId = entry.canastaId;
      _camion = List<InventarioCamionModel>.from(_camion)..[cIdx] = updated;
    } else if (cIdx != -1) {
      _camion = List<InventarioCamionModel>.from(_camion)..removeAt(cIdx);
    } else if (entry.cantidadCamion > 0) {
      _camion = List<InventarioCamionModel>.from(_camion)
        ..add(entry.toCamionModel());
    }

    final bIdx = _bodega.indexWhere((b) => b.productoId == entry.codigo);
    if (bIdx != -1 && entry.cantidadBodega > 0) {
      final updated = _bodega[bIdx]
        ..cantidad = entry.cantidadBodega;
      _bodega = List<InventarioBodegaModel>.from(_bodega)..[bIdx] = updated;
    } else if (bIdx != -1) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)..removeAt(bIdx);
    } else if (entry.cantidadBodega > 0) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)
        ..add(entry.toBodegaModel());
    }

    return _snapshot();
  }

  @override
  Future<InventorySnapshot> deleteProduct(String codigo) async {
    _productos = List<ProductoModel>.from(_productos)..removeWhere((p) => p.codigo == codigo);
    _camion = List<InventarioCamionModel>.from(_camion)..removeWhere((c) => c.productoId == codigo);
    _bodega = List<InventarioBodegaModel>.from(_bodega)..removeWhere((b) => b.productoId == codigo);
    return _snapshot();
  }
  @override
  Future<void> incrementBodegaStock(String productoId, int cantidad) async {
    final idx = _bodega.indexWhere((b) => b.productoId == productoId);
    if (idx == -1) {
      throw StateError('No hay registro de stock en la bodega para producto $productoId');
    }
    final model = _bodega[idx];
    final updated = InventarioBodegaModel()
      ..id = model.id
      ..codigo = model.codigo
      ..productoId = model.productoId
      ..cantidad = model.cantidad + cantidad;
    _bodega = List<InventarioBodegaModel>.from(_bodega)..[idx] = updated;
  }

  @override
  Future<void> createProductFromRecepcion(String productoId, int cantCamion, int cantBodega) async {
    // Verificar si el producto ya existe
    ProductoModel? existingProducto;
    for (final p in _productos) {
      if (p.codigo == productoId) {
        existingProducto = p;
        break;
      }
    }
    if (existingProducto != null) return;

    // Crear entrada mínima
    final productoModel = ProductoModel()
      ..codigo = productoId
      ..nombre = 'Producto $productoId'
      ..precio = 0
      ..isOriginal = false
      ..motosCompatibles = ''
      ..stockMinimo = 0;

    _productos = List<ProductoModel>.from(_productos)..add(productoModel);
    if (cantCamion > 0) {
      _camion = List<InventarioCamionModel>.from(_camion)..add(InventarioCamionModel()
        ..codigo = '${productoId}_CAMION'
        ..productoId = productoId
        ..canastaId = '0'
        ..cantidad = cantCamion);
    }
    if (cantBodega > 0) {
      _bodega = List<InventarioBodegaModel>.from(_bodega)..add(InventarioBodegaModel()
        ..codigo = '${productoId}_BODEGA'
        ..productoId = productoId
        ..cantidad = cantBodega);
    }
  }
}

InventoryRepository createInventoryRepository() => WebInventoryRepository();
