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
    // Descarga e inicializa el binario Isar Core requerido para pruebas unitarias en host local
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // Crea un directorio temporal único para aislar los archivos de base de datos de cada prueba
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
    // Limpieza de recursos y eliminación de base de datos de prueba
    await isar.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Debe persistir y consultar el inventario de bodega y camion filtrando por canasta', () async {
    // 2. Simular la creación de un producto
    // Nombre: "Cadena Honda Eco Deluxe", Precio: 45000
    final producto = ProductoModel()
      ..nombre = 'Cadena Honda Eco Deluxe'
      ..precio = 45000.0
      ..imagenUrl = 'https://supabase.example.com/stock/ch-100.png'
      ..isOriginal = true
      ..motosCompatibles = 'Honda Eco Deluxe, Hero Eco'
      ..stockMinimo = 5;

    await isar.writeTxn(() async {
      await isar.productoModels.put(producto);
    });

    // 3. Simular la asignación de stock:
    // - 50 unidades a Bodega Central
    // - 15 unidades al Camión asignadas a la "Canasta-A3" (mapeada al entero 3)
    final inventarioBodega = InventarioBodegaModel()
      ..productoId = producto.id
      ..cantidad = 50;

    final inventarioCamion = InventarioCamionModel()
      ..productoId = producto.id
      ..numeroCanasta = 3 // Mapeado de "Canasta-A3" a entero
      ..cantidad = 15;

    await isar.writeTxn(() async {
      await isar.inventarioBodegaModels.put(inventarioBodega);
      await isar.inventarioCamionModels.put(inventarioCamion);
    });

    // 4. Verificar que los datos se guarden correctamente y filtrar por número de canasta
    final bodegaSaved = await isar.inventarioBodegaModels
        .filter()
        .productoIdEqualTo(producto.id)
        .findFirst();

    final camionSaved = await isar.inventarioCamionModels
        .filter()
        .numeroCanastaEqualTo(3)
        .findFirst();

    // Verificaciones de Bodega
    expect(bodegaSaved, isNotNull);
    expect(bodegaSaved!.cantidad, equals(50));
    expect(bodegaSaved.productoId, equals(producto.id));

    // Verificaciones de Camión (filtrado por Canasta)
    expect(camionSaved, isNotNull);
    expect(camionSaved!.productoId, equals(producto.id));
    expect(camionSaved.cantidad, equals(15));
    expect(camionSaved.numeroCanasta, equals(3));
  });
}
