import 'package:super_motos/core/services/supabase_service.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_snapshot.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_exporter.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';
import 'package:super_motos/core/utils/import_progress.dart';

class WebInventoryRepository implements InventoryRepository {
  final InventoryCsvParser _parser = const InventoryCsvParser();
  final InventoryCsvExporter _exporter = const InventoryCsvExporter();

  @override
  Future<InventorySnapshot> loadInventory() async {
    try {
      final client = SupabaseService.instance.client;
      final prodRes = await client.from('productos').select();
      final camRes = await client.from('inventario_camion').select();
      final bodRes = await client.from('inventario_bodega').select();

      final productos = (prodRes as List<dynamic>).map((e) => _productoFromMap(e as Map<String, dynamic>)).toList();
      final camion = (camRes as List<dynamic>).map((e) => _camionFromMap(e as Map<String, dynamic>)).toList();
      final bodega = (bodRes as List<dynamic>).map((e) => _bodegaFromMap(e as Map<String, dynamic>)).toList();

      return InventorySnapshot(
        productos: productos,
        camion: camion,
        bodega: bodega,
      );
    } catch (e) {
      return InventorySnapshot.empty;
    }
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

    final client = SupabaseService.instance.client;

    // Delete existing records
    await client.from('inventario_camion').delete().neq('codigo', '');
    await client.from('inventario_bodega').delete().neq('codigo', '');
    await client.from('productos').delete().neq('codigo', '');

    final total = entries.length;
    int processed = 0;
    onProgress?.call(ImportProgress(processed: 0, total: total));

    for (final entry in entries) {
      if (cancelToken?.isCancelled == true) {
        throw StateError('Importación cancelada por el usuario');
      }

      await client.from('productos').insert({
        'codigo': entry.codigo,
        'nombre': entry.nombre,
        'precio': entry.precio,
        'is_original': entry.isOriginal,
        'motos_compatibles': entry.motosCompatibles,
        'stock_minimo': entry.stockMinimo,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (entry.cantidadCamion > 0) {
        await client.from('inventario_camion').insert({
          'codigo': '${entry.codigo}_CAMION',
          'producto_id': entry.codigo,
          'canasta_id': entry.canastaId,
          'cantidad': entry.cantidadCamion,
          'is_synced': true,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (entry.cantidadBodega > 0) {
        await client.from('inventario_bodega').insert({
          'codigo': '${entry.codigo}_BODEGA',
          'producto_id': entry.codigo,
          'cantidad': entry.cantidadBodega,
          'is_synced': true,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      processed++;
      onProgress?.call(ImportProgress(
        processed: processed,
        total: total,
        currentItem: entry.nombre,
      ));
    }

    onProgress?.call(ImportProgress(processed: total, total: total, done: true));
    return loadInventory();
  }

  @override
  Future<String> exportCsv() async {
    final snapshot = await loadInventory();
    final entries = <InventoryEntry>[];

    for (final producto in snapshot.productos) {
      final camion = snapshot.camion.firstWhere(
        (c) => c.productoId == producto.codigo,
        orElse: () => InventarioCamionModel()
          ..productoId = producto.codigo
          ..cantidad = 0
          ..canastaId = '0',
      );
      final bodega = snapshot.bodega.firstWhere(
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

  @override
  Future<void> decrementCamionStock(String productoId, int cantidad) async {
    final client = SupabaseService.instance.client;
    final res = await client
        .from('inventario_camion')
        .select()
        .eq('producto_id', productoId)
        .maybeSingle();
    if (res == null) {
      throw StateError('No hay registro de stock en el camion para producto $productoId');
    }
    final currentQty = res['cantidad'] as int? ?? 0;
    if (currentQty < cantidad) {
      throw StateError('Stock insuficiente en el camion para producto $productoId');
    }
    await client
        .from('inventario_camion')
        .update({'cantidad': currentQty - cantidad, 'updated_at': DateTime.now().toIso8601String()})
        .eq('producto_id', productoId);
  }

  @override
  Future<void> incrementCamionStock(String productoId, int cantidad) async {
    final client = SupabaseService.instance.client;
    final res = await client
        .from('inventario_camion')
        .select()
        .eq('producto_id', productoId)
        .maybeSingle();
    if (res == null) {
      throw StateError('No hay registro de stock en el camion para producto $productoId');
    }
    final currentQty = res['cantidad'] as int? ?? 0;
    await client
        .from('inventario_camion')
        .update({'cantidad': currentQty + cantidad, 'updated_at': DateTime.now().toIso8601String()})
        .eq('producto_id', productoId);
  }

  @override
  Future<void> incrementBodegaStock(String productoId, int cantidad) async {
    final client = SupabaseService.instance.client;
    final res = await client
        .from('inventario_bodega')
        .select()
        .eq('producto_id', productoId)
        .maybeSingle();
    if (res == null) {
      throw StateError('No hay registro de stock en la bodega para producto $productoId');
    }
    final currentQty = res['cantidad'] as int? ?? 0;
    await client
        .from('inventario_bodega')
        .update({'cantidad': currentQty + cantidad, 'updated_at': DateTime.now().toIso8601String()})
        .eq('producto_id', productoId);
  }

  @override
  Future<InventorySnapshot> createProduct(InventoryEntry entry) async {
    final client = SupabaseService.instance.client;
    await client.from('productos').insert({
      'codigo': entry.codigo,
      'nombre': entry.nombre,
      'precio': entry.precio,
      'is_original': entry.isOriginal,
      'motos_compatibles': entry.motosCompatibles,
      'stock_minimo': entry.stockMinimo,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
    if (entry.cantidadCamion > 0) {
      await client.from('inventario_camion').insert({
        'codigo': '${entry.codigo}_CAMION',
        'producto_id': entry.codigo,
        'canasta_id': entry.canastaId,
        'cantidad': entry.cantidadCamion,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    if (entry.cantidadBodega > 0) {
      await client.from('inventario_bodega').insert({
        'codigo': '${entry.codigo}_BODEGA',
        'producto_id': entry.codigo,
        'cantidad': entry.cantidadBodega,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    return loadInventory();
  }

  @override
  Future<InventorySnapshot> updateProduct(InventoryEntry entry) async {
    final client = SupabaseService.instance.client;
    await client.from('productos').update({
      'nombre': entry.nombre,
      'precio': entry.precio,
      'is_original': entry.isOriginal,
      'motos_compatibles': entry.motosCompatibles,
      'stock_minimo': entry.stockMinimo,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('codigo', entry.codigo);

    if (entry.cantidadCamion > 0) {
      await client.from('inventario_camion').upsert({
        'codigo': '${entry.codigo}_CAMION',
        'producto_id': entry.codigo,
        'canasta_id': entry.canastaId,
        'cantidad': entry.cantidadCamion,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      await client.from('inventario_camion').delete().eq('producto_id', entry.codigo);
    }

    if (entry.cantidadBodega > 0) {
      await client.from('inventario_bodega').upsert({
        'codigo': '${entry.codigo}_BODEGA',
        'producto_id': entry.codigo,
        'cantidad': entry.cantidadBodega,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      await client.from('inventario_bodega').delete().eq('producto_id', entry.codigo);
    }

    return loadInventory();
  }

  @override
  Future<InventorySnapshot> deleteProduct(String codigo) async {
    final client = SupabaseService.instance.client;
    await client.from('inventario_camion').delete().eq('producto_id', codigo);
    await client.from('inventario_bodega').delete().eq('producto_id', codigo);
    await client.from('productos').delete().eq('codigo', codigo);
    return loadInventory();
  }

  @override
  Future<void> createProductFromRecepcion(String productoId, int cantCamion, int cantBodega) async {
    final client = SupabaseService.instance.client;
    final existing = await client.from('productos').select().eq('codigo', productoId).maybeSingle();
    if (existing != null) return;

    await client.from('productos').insert({
      'codigo': productoId,
      'nombre': 'Producto $productoId',
      'precio': 0.0,
      'is_original': false,
      'motos_compatibles': '',
      'stock_minimo': 0,
      'is_synced': true,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (cantCamion > 0) {
      await client.from('inventario_camion').insert({
        'codigo': '${productoId}_CAMION',
        'producto_id': productoId,
        'canasta_id': '0',
        'cantidad': cantCamion,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    if (cantBodega > 0) {
      await client.from('inventario_bodega').insert({
        'codigo': '${productoId}_BODEGA',
        'producto_id': productoId,
        'cantidad': cantBodega,
        'is_synced': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  ProductoModel _productoFromMap(Map<String, dynamic> map) {
    return ProductoModel()
      ..codigo = map['codigo']?.toString() ?? ''
      ..nombre = (map['nombre'] ?? '').toString()
      ..precio = (map['precio'] as num?)?.toDouble() ?? 0.0
      ..imagenUrl = map['imagen_url']?.toString()
      ..isOriginal = map['is_original'] == true
      ..motosCompatibles = (map['motos_compatibles'] ?? '').toString()
      ..stockMinimo = (map['stock_minimo'] as num?)?.toInt() ?? 0
      ..isSynced = true;
  }

  InventarioCamionModel _camionFromMap(Map<String, dynamic> map) {
    return InventarioCamionModel()
      ..codigo = map['codigo']?.toString() ?? ''
      ..productoId = map['producto_id']?.toString() ?? ''
      ..canastaId = map['canasta_id']?.toString() ?? ''
      ..cantidad = (map['cantidad'] as num?)?.toInt() ?? 0
      ..isSynced = true;
  }

  InventarioBodegaModel _bodegaFromMap(Map<String, dynamic> map) {
    return InventarioBodegaModel()
      ..codigo = map['codigo']?.toString() ?? ''
      ..productoId = map['producto_id']?.toString() ?? ''
      ..cantidad = (map['cantidad'] as num?)?.toInt() ?? 0
      ..isSynced = true;
  }
}

InventoryRepository createInventoryRepository() => WebInventoryRepository();
