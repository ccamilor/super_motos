import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/features/suppliers/data/models/historial_precios_model.dart';
import 'package:super_motos/features/suppliers/data/models/proveedor_model.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_io.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

void main() {
  late Isar isar;
  late Directory tempDir;
  late IsarProveedoresRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_proveedores_test');

    isar = await Isar.open(
      [ProveedorModelSchema, HistorialPreciosModelSchema],
      directory: tempDir.path,
    );

    repository = IsarProveedoresRepository();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('create + loadAll: persists a provider and returns it', () async {
    final proveedor = Proveedor(
      codigo: 'PROV-001',
      nombre: 'Distribuidora Pegasus',
      nit: '800333444',
      telefono: '3009876543',
      direccion: 'Calle 7 #22-10, Medellin',
    );

    final created = await repository.create(proveedor);

    expect(created.codigo, equals('PROV-001'));
    expect(created.nombre, equals('Distribuidora Pegasus'));
    expect(created.nit, equals('800333444'));

    final all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.nombre, equals('Distribuidora Pegasus'));
  });

  test('update: modifies a provider and changes are visible after reload', () async {
    final created = await repository.create(Proveedor(
      codigo: 'PROV-002',
      nombre: 'Repuestos Moto JC',
      nit: '900111222',
      telefono: '3001234567',
      direccion: 'Cra 15 #45-30, Bogota',
    ));

    final updated = await repository.update(Proveedor(
      codigo: created.codigo,
      nombre: 'Repuestos Moto JC Actualizado',
      nit: '900111222',
      telefono: '3009998888',
      direccion: 'Cra 20 #55-40, Bogota',
    ));

    expect(updated.nombre, equals('Repuestos Moto JC Actualizado'));
    expect(updated.telefono, equals('3009998888'));

    final all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.nombre, equals('Repuestos Moto JC Actualizado'));
  });

  test('delete: removes a provider from storage', () async {
    final p1 = await repository.create(Proveedor(
      codigo: 'PROV-003',
      nombre: 'Proveedor A',
      nit: '111222',
      telefono: '3001111111',
      direccion: 'Dir A',
    ));
    final p2 = await repository.create(Proveedor(
      codigo: 'PROV-004',
      nombre: 'Proveedor B',
      nit: '333444',
      telefono: '3002222222',
      direccion: 'Dir B',
    ));

    var all = await repository.loadAll();
    expect(all, hasLength(2));

    await repository.delete(p1.codigo);

    all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.codigo, equals(p2.codigo));
    expect(all.first.nombre, equals('Proveedor B'));
  });

  test('loadAll: returns providers sorted alphabetically by nombre', () async {
    await repository.create(Proveedor(
      codigo: 'PROV-005',
      nombre: 'Zorro Repuestos',
      nit: '999888',
      telefono: '3003333333',
      direccion: 'Dir Z',
    ));
    await repository.create(Proveedor(
      codigo: 'PROV-006',
      nombre: 'Alpha Importaciones',
      nit: '111000',
      telefono: '3004444444',
      direccion: 'Dir A',
    ));
    await repository.create(Proveedor(
      codigo: 'PROV-007',
      nombre: 'Moto Distribuidora',
      nit: '555666',
      telefono: '3005555555',
      direccion: 'Dir M',
    ));

    final all = await repository.loadAll();

    expect(all, hasLength(3));
    expect(all[0].nombre, equals('Alpha Importaciones'));
    expect(all[1].nombre, equals('Moto Distribuidora'));
    expect(all[2].nombre, equals('Zorro Repuestos'));
  });
}
