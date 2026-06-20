import 'package:csv/csv.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

class InventoryCsvParser {
  const InventoryCsvParser();

  List<InventoryEntry> parse(String input) {
    final List<List<dynamic>> fields = csv.decode(input);
    if (fields.isEmpty) {
      return [];
    }

    final rows = <InventoryEntry>[];
    var startIndex = InventoryEntry.isHeaderRow(fields.first) ? 1 : 0;

    for (int i = startIndex; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 9) continue;
      rows.add(InventoryEntry.fromCsvRow(row, fallbackCodigo: 'AUTO-${i.toString().padLeft(3, '0')}'));
    }

    return rows;
  }
}
