import 'package:csv/csv.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

class InventoryCsvExporter {
  const InventoryCsvExporter();

  String export(List<InventoryEntry> entries) {
    final header = [
      'codigo',
      'nombre',
      'precio',
      'is_original',
      'motos_compatibles',
      'stock_minimo',
      'cantidad_camion',
      'canasta_id',
      'cantidad_bodega',
    ];

    final rows = entries
        .map((e) => [
              e.codigo,
              e.nombre,
              e.precio,
              e.isOriginal ? 'true' : 'false',
              e.motosCompatibles,
              e.stockMinimo,
              e.cantidadCamion,
              e.canastaId,
              e.cantidadBodega,
            ])
        .toList();

    return const CsvEncoder().convert([header, ...rows]);
  }
}
