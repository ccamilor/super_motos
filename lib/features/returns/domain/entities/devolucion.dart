class Devolucion {
  final int id;
  final String facturaId;
  final String productoId;
  final int cantidad;
  final String numeroCanastaDestino;
  final DateTime fechaDevolucion;
  final String motivo;
  final bool isSynced;

  Devolucion({
    required this.id,
    required this.facturaId,
    required this.productoId,
    required this.cantidad,
    required this.numeroCanastaDestino,
    required this.fechaDevolucion,
    required this.motivo,
    this.isSynced = false,
  });
}
