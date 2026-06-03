class Devolucion {
  final int id;
  final String facturaId;
  final String productoId;
  final int cantidad;
  final String numeroCanastaDestino;
  final DateTime fechaDevolucion;
  final String motivo;
  final bool isSynced;

  const Devolucion({
    required this.id,
    required this.facturaId,
    required this.productoId,
    required this.cantidad,
    required this.numeroCanastaDestino,
    required this.fechaDevolucion,
    required this.motivo,
    this.isSynced = false,
  });

  Devolucion copyWith({
    int? id,
    String? facturaId,
    String? productoId,
    int? cantidad,
    String? numeroCanastaDestino,
    DateTime? fechaDevolucion,
    String? motivo,
    bool? isSynced,
  }) {
    return Devolucion(
      id: id ?? this.id,
      facturaId: facturaId ?? this.facturaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      numeroCanastaDestino: numeroCanastaDestino ?? this.numeroCanastaDestino,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      motivo: motivo ?? this.motivo,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
