class HistorialPrecio {
  final String codigo;
  final String productoId;
  final String proveedorId;
  final double precioCompra;
  final DateTime fechaRegistro;
  final bool isSynced;

  HistorialPrecio({
    required this.codigo,
    required this.productoId,
    required this.proveedorId,
    required this.precioCompra,
    required this.fechaRegistro,
    this.isSynced = false,
  });

  HistorialPrecio copyWith({
    String? codigo,
    String? productoId,
    String? proveedorId,
    double? precioCompra,
    DateTime? fechaRegistro,
    bool? isSynced,
  }) {
    return HistorialPrecio(
      codigo: codigo ?? this.codigo,
      productoId: productoId ?? this.productoId,
      proveedorId: proveedorId ?? this.proveedorId,
      precioCompra: precioCompra ?? this.precioCompra,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
