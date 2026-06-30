import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/features/billing/data/models/factura_model.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';

void main() {
  late Isar isar;
  late Directory tempDir;
  late IsarFacturasRepository facturasRepo;
  late IsarInventoryRepository inventoryRepo;
  int _facturaCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_facturas_test');

    isar = await Isar.open(
      [
        FacturaModelSchema,
        ProductoModelSchema,
        InventarioBodegaModelSchema,
        InventarioCamionModelSchema,
      ],
      directory: tempDir.path,
    );

    facturasRepo = IsarFacturasRepository();
    inventoryRepo = IsarInventoryRepository();
    _facturaCounter = 0;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Factura buildFactura({DateTime? fecha, TipoPago tipoPago = TipoPago.contado, String? codigo}) {
    _facturaCounter++;
    return Factura(
      codigo: codigo ?? 'FAC-TEST-${_facturaCounter.toString().padLeft(3, '0')}',
      clienteId: 'CLI-001',
      vendedorId: 'USR-001',
      fecha: fecha ?? DateTime.now(),
      total: 50000,
      tipoPago: tipoPago,
      detalles: const [
        DetalleFactura(productoId: 'PROD-001', cantidad: 2, precioUnitario: 25000, subtotal: 50000),
      ],
    );
  }

  test('create + loadAll: persists a factura and returns it sorted by fecha desc', () async {
    final antigua = await facturasRepo.create(buildFactura(
      fecha: DateTime.now().subtract(const Duration(days: 10)),
    ));
    final reciente = await facturasRepo.create(buildFactura(
      fecha: DateTime.now().subtract(const Duration(days: 1)),
    ));

    final all = await facturasRepo.loadAll();
    expect(all, hasLength(2));
    expect(all.first.codigo, equals(reciente.codigo));
    expect(all.last.codigo, equals(antigua.codigo));
    expect(all.first.tipoPago, equals(TipoPago.contado));
  });

  test('getByCodigo: returns the factura with its detalles', () async {
    final creada = await facturasRepo.create(buildFactura());

    final fetched = await facturasRepo.getByCodigo(creada.codigo);

    expect(fetched, isNotNull);
    expect(fetched!.codigo, equals(creada.codigo));
    expect(fetched.clienteId, equals('CLI-001'));
    expect(fetched.detalles, hasLength(1));
    expect(fetched.detalles.first.productoId, equals('PROD-001'));
    expect(fetched.detalles.first.cantidad, equals(2));
    expect(fetched.detalles.first.subtotal, equals(50000));
  });

  test('getByCodigo: returns null for unknown codigo', () async {
    final result = await facturasRepo.getByCodigo('FAC-99999');
    expect(result, isNull);
  });

  test('delete: removes the factura from storage', () async {
    final f1 = await facturasRepo.create(buildFactura());
    final f2 = await facturasRepo.create(buildFactura());

    var all = await facturasRepo.loadAll();
    expect(all, hasLength(2));

    await facturasRepo.delete(f1.codigo);

    all = await facturasRepo.loadAll();
    expect(all, hasLength(1));
    expect(all.first.codigo, equals(f2.codigo));
  });

  test('decrementCamionStock: subtracts the cantidad from the camion stock', () async {
    final camion = InventarioCamionModel()
      ..codigo = 'CAMION-TEST-001'
      ..productoId = 'PROD-042'
      ..cantidad = 10
      ..canastaId = '1';
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });

    await inventoryRepo.decrementCamionStock('PROD-042', 3);

    final actualizado = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo('PROD-042')
        .findFirst();
    expect(actualizado, isNotNull);
    expect(actualizado!.cantidad, equals(7));
  });

  test('decrementCamionStock: throws StateError when stock is insufficient', () async {
    final camion = InventarioCamionModel()
      ..codigo = 'CAMION-TEST-002'
      ..productoId = 'PROD-050'
      ..cantidad = 2
      ..canastaId = '1';
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });

    expect(
      () => inventoryRepo.decrementCamionStock('PROD-050', 5),
      throwsA(isA<StateError>()),
    );

    final sinCambios = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo('PROD-050')
        .findFirst();
    expect(sinCambios!.cantidad, equals(2));
  });

  test('decrementCamionStock: throws StateError when no stock record exists', () async {
    expect(
      () => inventoryRepo.decrementCamionStock('PROD-9999', 1),
      throwsA(isA<StateError>()),
    );
  });

  test('update: persists changes to precioUnitario and sets isSynced to false', () async {
    final original = await facturasRepo.create(buildFactura());
    expect(original.detalles.first.precioUnitario, equals(25000));
    expect(original.total, equals(50000));

    final nuevosDetalles = [
      DetalleFactura(productoId: 'PROD-001', cantidad: 2, precioUnitario: 30000, subtotal: 60000),
    ];
    final modificada = original.copyWith(detalles: nuevosDetalles, total: 60000, isSynced: false);

    final updated = await facturasRepo.update(modificada);

    expect(updated.detalles.first.precioUnitario, equals(30000));
    expect(updated.total, equals(60000));
    expect(updated.isSynced, isFalse);

    final fetched = await facturasRepo.getByCodigo(original.codigo);
    expect(fetched, isNotNull);
    expect(fetched!.detalles.first.precioUnitario, equals(30000));
    expect(fetched.total, equals(60000));
  });

  test('update: preserves the original codigo and other fields', () async {
    final original = await facturasRepo.create(buildFactura(tipoPago: TipoPago.credito));

    final modificada = original.copyWith(total: 99999, isSynced: false);
    await facturasRepo.update(modificada);

    final fetched = await facturasRepo.getByCodigo(original.codigo);
    expect(fetched, isNotNull);
    expect(fetched!.codigo, equals(original.codigo));
    expect(fetched.clienteId, equals(original.clienteId));
    expect(fetched.vendedorId, equals(original.vendedorId));
    expect(fetched.tipoPago, equals(TipoPago.credito));
    expect(fetched.total, equals(99999));
  });

  test('DetalleFactura.copyWith: allows changing precioUnitario', () {
    const original = DetalleFactura(
      productoId: 'PROD-001',
      cantidad: 2,
      precioUnitario: 25000,
      subtotal: 50000,
    );

    final modified = original.copyWith(precioUnitario: 30000, subtotal: 60000);

    expect(modified.productoId, equals('PROD-001'));
    expect(modified.cantidad, equals(2));
    expect(modified.precioUnitario, equals(30000));
    expect(modified.subtotal, equals(60000));
  });

  test('Factura.copyWith: allows changing detalles and total', () {
    final original = Factura(
      codigo: 'FAC-001',
      clienteId: 'CLI-001',
      vendedorId: 'USR-001',
      fecha: DateTime(2026, 1, 1),
      total: 50000,
      tipoPago: TipoPago.contado,
      detalles: const [
        DetalleFactura(productoId: 'PROD-001', cantidad: 2, precioUnitario: 25000, subtotal: 50000),
      ],
      isSynced: true,
    );

    final newDetalles = [
      DetalleFactura(productoId: 'PROD-001', cantidad: 2, precioUnitario: 30000, subtotal: 60000),
    ];
    final modified = original.copyWith(detalles: newDetalles, total: 60000, isSynced: false);

    expect(modified.codigo, equals('FAC-001'));
    expect(modified.total, equals(60000));
    expect(modified.isSynced, isFalse);
    expect(modified.detalles.first.precioUnitario, equals(30000));
  });
}
