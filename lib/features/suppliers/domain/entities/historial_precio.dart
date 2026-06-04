class HistorialPrecio {
  final int id;
  final String productoId;
  final String proveedorId;
  final double precioCompra;
  final DateTime fechaRegistro;
  final bool isSynced;

  HistorialPrecio({
    required this.id,
    required this.productoId,
    required this.proveedorId,
    required this.precioCompra,
    required this.fechaRegistro,
    this.isSynced = false,
  });

  HistorialPrecio copyWith({
    int? id,
    String? productoId,
    String? proveedorId,
    double? precioCompra,
    DateTime? fechaRegistro,
    bool? isSynced,
  }) {
    return HistorialPrecio(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      proveedorId: proveedorId ?? this.proveedorId,
      precioCompra: precioCompra ?? this.precioCompra,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}