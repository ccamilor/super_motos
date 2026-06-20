class Devolucion {
  final String codigo;
  final String facturaId;
  final String productoId;
  final int cantidad;
  final String canastaDestino;
  final DateTime fechaDevolucion;
  final String motivo;
  final bool isSynced;

  const Devolucion({
    required this.codigo,
    required this.facturaId,
    required this.productoId,
    required this.cantidad,
    required this.canastaDestino,
    required this.fechaDevolucion,
    required this.motivo,
    this.isSynced = false,
  });

  Devolucion copyWith({
    String? codigo,
    String? facturaId,
    String? productoId,
    int? cantidad,
    String? canastaDestino,
    DateTime? fechaDevolucion,
    String? motivo,
    bool? isSynced,
  }) {
    return Devolucion(
      codigo: codigo ?? this.codigo,
      facturaId: facturaId ?? this.facturaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      canastaDestino: canastaDestino ?? this.canastaDestino,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      motivo: motivo ?? this.motivo,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
