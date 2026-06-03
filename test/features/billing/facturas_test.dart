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
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Factura buildFactura({DateTime? fecha, TipoPago tipoPago = TipoPago.contado}) {
    return Factura(
      numeroFactura: 0,
      clienteId: 1,
      vendedorId: 1,
      fecha: fecha ?? DateTime.now(),
      total: 50000,
      tipoPago: tipoPago,
      detalles: const [
        DetalleFactura(productoId: 1, cantidad: 2, precioUnitario: 25000, subtotal: 50000),
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
    expect(all.first.numeroFactura, equals(reciente.numeroFactura));
    expect(all.last.numeroFactura, equals(antigua.numeroFactura));
    expect(all.first.tipoPago, equals(TipoPago.contado));
  });

  test('getById: returns the factura with its detalles', () async {
    final creada = await facturasRepo.create(buildFactura());

    final fetched = await facturasRepo.getById(creada.numeroFactura);

    expect(fetched, isNotNull);
    expect(fetched!.numeroFactura, equals(creada.numeroFactura));
    expect(fetched.clienteId, equals(1));
    expect(fetched.detalles, hasLength(1));
    expect(fetched.detalles.first.productoId, equals(1));
    expect(fetched.detalles.first.cantidad, equals(2));
    expect(fetched.detalles.first.subtotal, equals(50000));
  });

  test('getById: returns null for unknown id', () async {
    final result = await facturasRepo.getById(99999);
    expect(result, isNull);
  });

  test('delete: removes the factura from storage', () async {
    final f1 = await facturasRepo.create(buildFactura());
    final f2 = await facturasRepo.create(buildFactura());

    var all = await facturasRepo.loadAll();
    expect(all, hasLength(2));

    await facturasRepo.delete(f1.numeroFactura);

    all = await facturasRepo.loadAll();
    expect(all, hasLength(1));
    expect(all.first.numeroFactura, equals(f2.numeroFactura));
  });

  test('decrementCamionStock: subtracts the cantidad from the camion stock', () async {
    final camion = InventarioCamionModel()
      ..productoId = 42
      ..cantidad = 10
      ..numeroCanasta = 1;
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });

    await inventoryRepo.decrementCamionStock(42, 3);

    final actualizado = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo(42)
        .findFirst();
    expect(actualizado, isNotNull);
    expect(actualizado!.cantidad, equals(7));
  });

  test('decrementCamionStock: throws StateError when stock is insufficient', () async {
    final camion = InventarioCamionModel()
      ..productoId = 50
      ..cantidad = 2
      ..numeroCanasta = 1;
    await isar.writeTxn(() async {
      await isar.inventarioCamionModels.put(camion);
    });

    expect(
      () => inventoryRepo.decrementCamionStock(50, 5),
      throwsA(isA<StateError>()),
    );

    final sinCambios = await isar.inventarioCamionModels
        .filter()
        .productoIdEqualTo(50)
        .findFirst();
    expect(sinCambios!.cantidad, equals(2));
  });

  test('decrementCamionStock: throws StateError when no stock record exists', () async {
    expect(
      () => inventoryRepo.decrementCamionStock(9999, 1),
      throwsA(isA<StateError>()),
    );
  });
}
