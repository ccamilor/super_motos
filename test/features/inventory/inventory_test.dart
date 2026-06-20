import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';

void main() {
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_test');

    isar = await Isar.open(
      [
        ProductoModelSchema,
        InventarioBodegaModelSchema,
        InventarioCamionModelSchema,
      ],
      directory: tempDir.path,
    );
  });

  tearDown(() async {
    await isar.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Debe persistir y consultar el inventario de bodega y camion filtrando por canasta', () async {
    final producto = ProductoModel()
      ..codigo = 'PROD-TEST-001'
      ..nombre = 'Cadena Honda Eco Deluxe'
      ..precio = 45000.0
      ..imagenUrl = 'https://supabase.example.com/stock/ch-100.png'
      ..isOriginal = true
      ..motosCompatibles = 'Honda Eco Deluxe, Hero Eco'
      ..stockMinimo = 5;

    await isar.writeTxn(() async {
      await isar.productoModels.put(producto);
    });

    final inventarioBodega = InventarioBodegaModel()
      ..codigo = '${producto.codigo}_BODEGA'
      ..productoId = producto.codigo
      ..cantidad = 50;

    final inventarioCamion = InventarioCamionModel()
      ..codigo = '${producto.codigo}_CAMION'
      ..productoId = producto.codigo
      ..canastaId = '3'
      ..cantidad = 15;

    await isar.writeTxn(() async {
      await isar.inventarioBodegaModels.put(inventarioBodega);
      await isar.inventarioCamionModels.put(inventarioCamion);
    });

    final bodegaSaved = await isar.inventarioBodegaModels
        .filter()
        .productoIdEqualTo(producto.codigo)
        .findFirst();

    final camionSaved = await isar.inventarioCamionModels
        .filter()
        .canastaIdEqualTo('3')
        .findFirst();

    expect(bodegaSaved, isNotNull);
    expect(bodegaSaved!.cantidad, equals(50));
    expect(bodegaSaved.productoId, equals(producto.codigo));

    expect(camionSaved, isNotNull);
    expect(camionSaved!.productoId, equals(producto.codigo));
    expect(camionSaved.cantidad, equals(15));
    expect(camionSaved.canastaId, equals('3'));
  });
}
