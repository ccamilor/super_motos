import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';

class InventoryEntry {
  final int id;
  final String nombre;
  final double precio;
  final bool isOriginal;
  final String motosCompatibles;
  final int stockMinimo;
  final int cantidadCamion;
  final int numeroCanasta;
  final int cantidadBodega;

  const InventoryEntry({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.isOriginal,
    required this.motosCompatibles,
    required this.stockMinimo,
    required this.cantidadCamion,
    required this.numeroCanasta,
    required this.cantidadBodega,
  });

  factory InventoryEntry.fromCsvRow(List<dynamic> row, {required int fallbackId}) {
    final idVal = int.tryParse(row[0].toString().trim()) ?? fallbackId;
    final nombreVal = row[1].toString().trim();
    final precioVal = double.tryParse(row[2].toString().trim()) ?? 0.0;
    final isOriginalVal = row[3].toString().trim().toLowerCase() == 'true' ||
        row[3].toString().trim() == '1';
    final motosCompatiblesVal = row[4].toString().trim();
    final stockMinimoVal = int.tryParse(row[5].toString().trim()) ?? 0;
    final cantidadCamionVal = int.tryParse(row[6].toString().trim()) ?? 0;
    final numeroCanastaVal = int.tryParse(row[7].toString().trim()) ?? 0;
    final cantidadBodegaVal = int.tryParse(row[8].toString().trim()) ?? 0;

    return InventoryEntry(
      id: idVal,
      nombre: nombreVal,
      precio: precioVal,
      isOriginal: isOriginalVal,
      motosCompatibles: motosCompatiblesVal,
      stockMinimo: stockMinimoVal,
      cantidadCamion: cantidadCamionVal,
      numeroCanasta: numeroCanastaVal,
      cantidadBodega: cantidadBodegaVal,
    );
  }

  static bool isHeaderRow(List<dynamic> row) {
    if (row.isEmpty) return false;
    final firstCell = row[0].toString().trim().toLowerCase();
    final secondCell = row.length > 1 ? row[1].toString().trim().toLowerCase() : '';
    return firstCell == 'id' || secondCell == 'nombre';
  }

  ProductoModel toProductoModel() {
    return ProductoModel()
      ..id = id
      ..nombre = nombre
      ..precio = precio
      ..isOriginal = isOriginal
      ..motosCompatibles = motosCompatibles
      ..stockMinimo = stockMinimo;
  }

  InventarioCamionModel toCamionModel() {
    return InventarioCamionModel()
      ..productoId = id
      ..cantidad = cantidadCamion
      ..numeroCanasta = numeroCanasta;
  }

  InventarioBodegaModel toBodegaModel() {
    return InventarioBodegaModel()
      ..productoId = id
      ..cantidad = cantidadBodega;
  }
}
