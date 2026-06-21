class DetalleRecepcion {
  final String productoId;
  final int cantidad;
  final double precioUnitario;
  final String destino;
  final int? cantidadCamion;
  final int? cantidadBodega;

  const DetalleRecepcion({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.destino,
    this.cantidadCamion,
    this.cantidadBodega,
  });

  double get subtotal => cantidad * precioUnitario;
}
