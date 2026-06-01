import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/data/services/inventory_seed_data.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

void main() {
  group('Inventory CSV flow', () {
    late String csvContent;
    late List<List<dynamic>> fields;
    late List<InventoryEntry> parsedEntries;

    setUp(() {
      final file = File('test_data/inventario_prueba.csv');
      csvContent = file.readAsStringSync();
      fields = csv.decode(csvContent);
      parsedEntries = const InventoryCsvParser().parse(csvContent);
    });

    test('CSV file exists and is not empty', () {
      expect(csvContent.isNotEmpty, true);
    });

    test('CSV contains 1 header row plus 12 data rows', () {
      expect(fields.length, 13);
      expect(parsedEntries.length, 12);
    });

    test('Header row is detected correctly', () {
      expect(InventoryEntry.isHeaderRow(fields.first), true);
    });

    test('Every parsed row has valid numeric data', () {
      for (final entry in parsedEntries) {
        expect(entry.id >= 100, true);
        expect(entry.precio > 0, true);
        expect(entry.stockMinimo >= 0, true);
        expect(entry.cantidadCamion >= 0, true);
        expect(entry.numeroCanasta >= 0, true);
        expect(entry.cantidadBodega >= 0, true);
      }
    });

    test('First and last CSV rows map into expected entries', () {
      final first = parsedEntries.first;
      final last = parsedEntries.last;

      expect(first.id, 101);
      expect(first.nombre, 'Cadena Reforzada 428H-130L');
      expect(first.precio, 35000.0);
      expect(first.isOriginal, true);
      expect(first.cantidadCamion, 12);
      expect(first.cantidadBodega, 50);

      expect(last.id, 112);
      expect(last.nombre, 'Espejos Retrovisores Deportivos');
      expect(last.precio, 16000.0);
      expect(last.isOriginal, false);
    });

    test('Seed data stays aligned with the demo inventory', () {
      expect(InventorySeedData.demoEntries.length, 6);
      expect(InventorySeedData.demoEntries.first.nombre, 'Kit de Arrastre Racing Oro');
      expect(InventorySeedData.demoEntries.last.cantidadBodega, 30);
    });

    test('COP formatter behavior stays stable', () {
      String formatCOP(double precio) {
        final valorEntero = precio.toInt();
        final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
        final formateado = valorEntero.toString().replaceAllMapped(reg, (match) => '${match[1]}.');
        return '\$ $formateado COP';
      }

      expect(formatCOP(35000), '\$ 35.000 COP');
      expect(formatCOP(185000), '\$ 185.000 COP');
      expect(formatCOP(12500), '\$ 12.500 COP');
      expect(formatCOP(92000), '\$ 92.000 COP');
    });
  });
}
