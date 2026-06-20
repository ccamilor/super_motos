import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/data/models/cliente_model.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

void main() {
  late Isar isar;
  late Directory tempDir;
  late IsarClientesRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('super_motos_clientes_test');

    isar = await Isar.open(
      [ClienteModelSchema],
      directory: tempDir.path,
    );

    repository = IsarClientesRepository();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('create + loadAll: persists a new client and returns it', () async {
    final cliente = Cliente(
      codigo: 'CLI-001',
      nombre: 'Taller El Rayo',
      identificadorFiscal: '123456789',
      direccion: 'Cra 50 #10-20, Bogota',
      limiteCredito: 1500000,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    );

    final created = await repository.create(cliente);

    expect(created.codigo, equals('CLI-001'));
    expect(created.nombre, equals('Taller El Rayo'));
    expect(created.estadoCuenta, equals(EstadoCuenta.activo));

    final all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.nombre, equals('Taller El Rayo'));
    expect(all.first.identificadorFiscal, equals('123456789'));
  });

  test('update: modifies a client and changes are visible after reload', () async {
    final created = await repository.create(Cliente(
      codigo: 'CLI-002',
      nombre: 'Cliente Original',
      identificadorFiscal: '111222333',
      direccion: 'Calle 1',
      limiteCredito: 500000,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));

    final updated = await repository.update(Cliente(
      codigo: created.codigo,
      nombre: 'Cliente Renombrado',
      identificadorFiscal: '111222333',
      direccion: 'Calle 2',
      limiteCredito: 800000,
      saldoPendiente: 100000,
      estadoCuenta: EstadoCuenta.suspendido,
    ));

    expect(updated.nombre, equals('Cliente Renombrado'));
    expect(updated.limiteCredito, equals(800000));
    expect(updated.estadoCuenta, equals(EstadoCuenta.suspendido));

    final all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.nombre, equals('Cliente Renombrado'));
    expect(all.first.limiteCredito, equals(800000));
  });

  test('delete: removes a client from storage', () async {
    final c1 = await repository.create(Cliente(
      codigo: 'CLI-003',
      nombre: 'Cliente A',
      identificadorFiscal: '111',
      direccion: 'Dir A',
      limiteCredito: 100,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));
    final c2 = await repository.create(Cliente(
      codigo: 'CLI-004',
      nombre: 'Cliente B',
      identificadorFiscal: '222',
      direccion: 'Dir B',
      limiteCredito: 200,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));

    var all = await repository.loadAll();
    expect(all, hasLength(2));

    await repository.delete(c1.codigo);

    all = await repository.loadAll();
    expect(all, hasLength(1));
    expect(all.first.codigo, equals(c2.codigo));
    expect(all.first.nombre, equals('Cliente B'));
  });

  test('loadAll: returns clients sorted alphabetically by nombre', () async {
    await repository.create(Cliente(
      codigo: 'CLI-005',
      nombre: 'Zorro Repuestos',
      identificadorFiscal: '999',
      direccion: 'Dir',
      limiteCredito: 100,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));
    await repository.create(Cliente(
      codigo: 'CLI-006',
      nombre: 'Alpha Motos',
      identificadorFiscal: '111',
      direccion: 'Dir',
      limiteCredito: 100,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));
    await repository.create(Cliente(
      codigo: 'CLI-007',
      nombre: 'Moto Service',
      identificadorFiscal: '555',
      direccion: 'Dir',
      limiteCredito: 100,
      saldoPendiente: 0,
      estadoCuenta: EstadoCuenta.activo,
    ));

    final all = await repository.loadAll();

    expect(all, hasLength(3));
    expect(all[0].nombre, equals('Alpha Motos'));
    expect(all[1].nombre, equals('Moto Service'));
    expect(all[2].nombre, equals('Zorro Repuestos'));
  });
}
