class InventarioCamion {
  final int productoId;
  final int numeroCanasta;
  final int cantidad;
  final bool isSynced;

  InventarioCamion({
    required this.productoId,
    required this.numeroCanasta,
    required this.cantidad,
    this.isSynced = false,
  });
}
