import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/returns/data/models/devolucion_model.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository_io.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

void main() {
  late Isar isar;
  late Directory tempDir;
  late IsarDevolucionesRepository devolucionesRepo;
  late IsarInventoryRepository inventoryRepo;
  int _devolucionCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_devoluciones_test');

    isar = await Isar.open(
      [
        DevolucionModelSchema,
        ProductoModelSchema,
        InventarioBodegaModelSchema,
        InventarioCamionModelSchema,
      ],
      directory: tempDir.path,
    );

    devolucionesRepo = IsarDevolucionesRepository();
    inventoryRepo = IsarInventoryRepository();
    _devolucionCounter = 0;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Devolucion buildDevolucion({DateTime? fecha, String motivo = 'Defecto de fabrica', String? codigo}) {
    _devolucionCounter++;
    return Devolucion(
      codigo: codigo ?? 'DEV-TEST-${_devolucionCounter.toString().padLeft(3, '0')}',
      facturaId: '1',
      productoId: '3',
      cantidad: 2,
      canastaDestino: 'A2',
      fechaDevolucion: fecha ?? DateTime.now(),
      motivo: motivo,
    );
  }

  test('create + loadAll: persists and returns sorted by fechaDevolucion desc', () async {
    final antigua = await devolucionesRepo.create(buildDevolucion(
      fecha: DateTime.now().subtract(const Duration(days: 10)),
    ));
    final reciente = await devolucionesRepo.create(buildDevolucion(
      fecha: DateTime.now().subtract(const Duration(days: 1)),
    ));

    final all = await devolucionesRepo.loadAll();
    expect(all, hasLength(2));
    expect(all.first.codigo, equals(reciente.codigo));
    expect(all.last.codigo, equals(antigua.codigo));
    expect(all.first.motivo, equals('Defecto de fabrica'));
  });

  test('getByCodigo: returns the devolucion with all fields intact', () async {
    final creada = await devolucionesRepo.create(Devolucion(
      codigo: 'DEV-TEST-099',
      facturaId: '42',
      productoId: '7',
      cantidad: 5,
      canastaDestino: 'C3',
      fechaDevolucion: DateTime(2026, 1, 15),
      motivo: 'Cambio de opinion',
    ));

    final fetched = await devolucionesRepo.getByCodigo(creada.codigo);

    expect(fetched, isNotNull);
    expect(fetched!.facturaId, equals('42'));
    expect(fetched.productoId, equals('7'));
    expect(fetched.cantidad, equals(5));
    expect(fetched.canastaDestino, equals('C3'));
    expect(fetched.motivo, equals('Cambio de opinion'));
    expect(fetched.fechaDevolucion, equals(DateTime(2026, 1, 15)));
  });

  test('getByCodigo: returns null for unknown codigo', () async {
    final result = await devolucionesRepo.getByCodigo('DEV-99999');
    expect(result, isNull);
  });

  test('delete: removes the devolucion from storage', () async {
    final d1 = await devolucionesRepo.create(buildDevolucion(motivo: 'A'));
    final d2 = await devolucionesRepo.create(buildDevolucion(motivo: 'B'));

    var all = await devolucionesRepo.loadAll();
    expect(all, hasLength(2));

    await devolucionesRepo.delete(d1.codigo);

    all = await devolucionesRepo.loadAll();
    expect(all, hasLength(1));
    expect(all.first.codigo, equals(d2.codigo));
    expect(all.first.motivo, equals('B'));
  });

  test('incrementCamionStock: adds the cantidad to the existing camion stock', () async {
    final camion = InventarioCamionModel()
      ..codigo = 'CAMION-TEST-099'
      ..productoId = 'PROD-099'
      ..cantidad = 5
      ..canastaId = '1';
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });

    await inventoryRepo.incrementCamionStock('PROD-099', 3);

    final actualizado = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo('PROD-099')
        .findFirst();
    expect(actualizado, isNotNull);
    expect(actualizado!.cantidad, equals(8));
  });

  test('incrementCamionStock: throws StateError when no stock record exists', () async {
    expect(
      () => inventoryRepo.incrementCamionStock('PROD-9999', 1),
      throwsA(isA<StateError>()),
    );
  });
}
