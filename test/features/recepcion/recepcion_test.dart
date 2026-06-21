import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/recepcion/data/models/recepcion_model.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_io.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository_io.dart';

void main() {
  late Isar isar;
  late Directory tempDir;
  late IsarRecepcionRepository recepcionRepo;
  late IsarInventoryRepository inventoryRepo;
  late IsarHistorialPreciosRepository historialRepo;
  int _recepcionCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_recepcion_test');

    isar = await Isar.open(
      [
        RecepcionModelSchema,
        ProductoModelSchema,
        InventarioCamionModelSchema,
        InventarioBodegaModelSchema,
        ProveedorModelSchema,
        HistorialPreciosModelSchema,
      ],
      directory: tempDir.path,
    );

    inventoryRepo = IsarInventoryRepository();
    historialRepo = IsarHistorialPreciosRepository();
    recepcionRepo = IsarRecepcionRepository(
      inventoryRepo: inventoryRepo,
      historialRepo: historialRepo,
    );
    _recepcionCounter = 0;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Recepcion buildRecepcion({
    String? proveedorId,
    DateTime? fecha,
    List<DetalleRecepcion>? detalles,
    String? nroRemito,
  }) {
    _recepcionCounter++;
    return Recepcion(
      codigo: 'REC-TEST-${_recepcionCounter.toString().padLeft(3, '0')}',
      proveedorId: proveedorId ?? 'PROV-001',
      fecha: fecha ?? DateTime.now(),
      nroRemito: nroRemito ?? 'RM-TEST-$_recepcionCounter',
      observaciones: 'Test recepcion $_recepcionCounter',
      detalles: detalles ?? [
        const DetalleRecepcion(
          productoId: 'PROD-001',
          cantidad: 10,
          precioUnitario: 5000,
          destino: 'camion',
        ),
      ],
    );
  }

  Future<void> _seedProducto(String codigo, {int cantCamion = 0, int cantBodega = 0}) async {
    final producto = ProductoModel()
      ..codigo = codigo
      ..nombre = 'Producto $codigo'
      ..precio = 1000
      ..isOriginal = true
      ..motosCompatibles = 'Test'
      ..stockMinimo = 5;
    await isar.writeTxn(() async {
      await isar.productoModels.put(producto);
    });
    final camion = InventarioCamionModel()
      ..codigo = '${codigo}_CAMION'
      ..productoId = codigo
      ..canastaId = 'A-1'
      ..cantidad = cantCamion;
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });
    final bodega = InventarioBodegaModel()
      ..codigo = '${codigo}_BODEGA'
      ..productoId = codigo
      ..cantidad = cantBodega;
    await isar.writeTxn(() async {
      await isar.inventarioBodegaModels.put(bodega);
    });
  }

  group('CRUD basico', () {
    test('create + loadAll: persists a recepcion and returns it sorted by fecha desc', () async {
      final antigua = await recepcionRepo.create(buildRecepcion(
        fecha: DateTime.now().subtract(const Duration(days: 10)),
      ));
      final reciente = await recepcionRepo.create(buildRecepcion(
        fecha: DateTime.now().subtract(const Duration(days: 1)),
      ));

      final all = await recepcionRepo.loadAll();
      expect(all, hasLength(2));
      expect(all.first.codigo, equals(reciente.codigo));
      expect(all.last.codigo, equals(antigua.codigo));
      expect(all.first.proveedorId, equals('PROV-001'));
    });

    test('loadByProveedor: returns only recepciones for the given proveedorId', () async {
      await recepcionRepo.create(buildRecepcion(proveedorId: 'PROV-001'));
      await recepcionRepo.create(buildRecepcion(proveedorId: 'PROV-002'));
      await recepcionRepo.create(buildRecepcion(proveedorId: 'PROV-001'));

      final prov1 = await recepcionRepo.loadByProveedor('PROV-001');
      expect(prov1, hasLength(2));
      expect(prov1.every((r) => r.proveedorId == 'PROV-001'), isTrue);

      final prov2 = await recepcionRepo.loadByProveedor('PROV-002');
      expect(prov2, hasLength(1));
      expect(prov2.first.proveedorId, equals('PROV-002'));
    });

    test('getByCodigo: returns the recepcion with its detalles', () async {
      final detalles = [
        const DetalleRecepcion(
          productoId: 'PROD-001',
          cantidad: 10,
          precioUnitario: 5000,
          destino: 'camion',
        ),
        const DetalleRecepcion(
          productoId: 'PROD-002',
          cantidad: 20,
          precioUnitario: 3000,
          destino: 'bodega',
        ),
      ];
      final creada = await recepcionRepo.create(buildRecepcion(detalles: detalles));

      final fetched = await recepcionRepo.getByCodigo(creada.codigo);

      expect(fetched, isNotNull);
      expect(fetched!.codigo, equals(creada.codigo));
      expect(fetched.proveedorId, equals('PROV-001'));
      expect(fetched.nroRemito, equals('RM-TEST-1'));
      expect(fetched.detalles, hasLength(2));
      expect(fetched.detalles[0].productoId, equals('PROD-001'));
      expect(fetched.detalles[0].destino, equals('camion'));
      expect(fetched.detalles[1].productoId, equals('PROD-002'));
      expect(fetched.detalles[1].destino, equals('bodega'));
    });

    test('getByCodigo: returns null for unknown codigo', () async {
      final result = await recepcionRepo.getByCodigo('REC-99999');
      expect(result, isNull);
    });

    test('delete: removes the recepcion from storage', () async {
      final r1 = await recepcionRepo.create(buildRecepcion());
      final r2 = await recepcionRepo.create(buildRecepcion());

      var all = await recepcionRepo.loadAll();
      expect(all, hasLength(2));

      await recepcionRepo.delete(r1.codigo);

      all = await recepcionRepo.loadAll();
      expect(all, hasLength(1));
      expect(all.first.codigo, equals(r2.codigo));
    });
  });

  group('Incremento de stock', () {
    test('create: increments camion stock for destino=camion', () async {
      await _seedProducto('PROD-010', cantCamion: 5);

      final recepcion = buildRecepcion(
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-010',
            cantidad: 15,
            precioUnitario: 8000,
            destino: 'camion',
          ),
        ],
      );
      await recepcionRepo.create(recepcion);

      final camion = await isar.inventarioCamionModels
          .filter()
          .productoIdEqualTo('PROD-010')
          .findFirst();
      expect(camion, isNotNull);
      expect(camion!.cantidad, equals(20)); // 5 + 15
    });

    test('create: increments bodega stock for destino=bodega', () async {
      await _seedProducto('PROD-011', cantBodega: 10);

      final recepcion = buildRecepcion(
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-011',
            cantidad: 25,
            precioUnitario: 6000,
            destino: 'bodega',
          ),
        ],
      );
      await recepcionRepo.create(recepcion);

      final bodega = await isar.inventarioBodegaModels
          .filter()
          .productoIdEqualTo('PROD-011')
          .findFirst();
      expect(bodega, isNotNull);
      expect(bodega!.cantidad, equals(35)); // 10 + 25
    });

    test('create: splits stock correctly for destino=split', () async {
      await _seedProducto('PROD-012', cantCamion: 0, cantBodega: 0);

      final recepcion = buildRecepcion(
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-012',
            cantidad: 30,
            precioUnitario: 7000,
            destino: 'split',
            cantidadCamion: 10,
            cantidadBodega: 20,
          ),
        ],
      );
      await recepcionRepo.create(recepcion);

      final camion = await isar.inventarioCamionModels
          .filter()
          .productoIdEqualTo('PROD-012')
          .findFirst();
      expect(camion, isNotNull);
      expect(camion!.cantidad, equals(10));

      final bodega = await isar.inventarioBodegaModels
          .filter()
          .productoIdEqualTo('PROD-012')
          .findFirst();
      expect(bodega, isNotNull);
      expect(bodega!.cantidad, equals(20));
    });
  });

  group('Upsert HistorialPrecio', () {
    test('create: upserts HistorialPrecio with real price', () async {
      final recepcion = buildRecepcion(
        proveedorId: 'PROV-050',
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-020',
            cantidad: 5,
            precioUnitario: 12000,
            destino: 'camion',
          ),
        ],
      );
      await recepcionRepo.create(recepcion);

      final historial = await historialRepo.loadByProveedorId('PROV-050');
      expect(historial, hasLength(1));
      expect(historial.first.productoId, equals('PROD-020'));
      expect(historial.first.precioCompra, equals(12000));
    });

    test('create: updates HistorialPrecio price on second recepcion', () async {
      final r1 = buildRecepcion(
        proveedorId: 'PROV-060',
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-030',
            cantidad: 5,
            precioUnitario: 10000,
            destino: 'camion',
          ),
        ],
      );
      await recepcionRepo.create(r1);

      final r2 = buildRecepcion(
        proveedorId: 'PROV-060',
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-030',
            cantidad: 10,
            precioUnitario: 15000,
            destino: 'camion',
          ),
        ],
      );
      await recepcionRepo.create(r2);

      final historial = await historialRepo.loadByProveedorId('PROV-060');
      expect(historial, hasLength(1));
      expect(historial.first.precioCompra, equals(15000)); // Updated price
    });
  });

  group('Sync', () {
    test('create: enqueues recepcion in sync queue', () async {
      await SyncService.instance.init();
      final initialCount = SyncService.instance.getUnsyncedCount('recepciones');

      await recepcionRepo.create(buildRecepcion());

      final finalCount = SyncService.instance.getUnsyncedCount('recepciones');
      expect(finalCount, equals(initialCount + 1));
    });
  });

  group('Validaciones', () {
    test('create: throws StateError when split quantities don\'t match total', () async {
      await _seedProducto('PROD-040', cantCamion: 0, cantBodega: 0);

      final recepcion = buildRecepcion(
        detalles: [
          const DetalleRecepcion(
            productoId: 'PROD-040',
            cantidad: 30,
            precioUnitario: 7000,
            destino: 'split',
            cantidadCamion: 10,
            cantidadBodega: 15, // 10 + 15 != 30
          ),
        ],
      );

      expect(
        () => recepcionRepo.create(recepcion),
        throwsA(isA<StateError>()),
      );
    });
  });
}
