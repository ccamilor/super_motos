class InventarioCamion {
  final String productoId;
  final String canastaId;
  final int cantidad;
  final bool isSynced;

  InventarioCamion({
    required this.productoId,
    required this.canastaId,
    required this.cantidad,
    this.isSynced = false,
  });
}
