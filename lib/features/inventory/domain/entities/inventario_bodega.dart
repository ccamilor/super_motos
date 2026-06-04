class InventarioBodega {
  final int productoId;
  final int cantidad;
  final bool isSynced;

  InventarioBodega({
    required this.productoId,
    required this.cantidad,
    this.isSynced = false,
  });
}
