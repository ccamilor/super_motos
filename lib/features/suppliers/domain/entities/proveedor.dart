class Proveedor {
  final String codigo;
  final String nombre;
  final String nit;
  final String telefono;
  final String direccion;
  final bool isSynced;

  Proveedor({
    required this.codigo,
    required this.nombre,
    required this.nit,
    required this.telefono,
    required this.direccion,
    this.isSynced = false,
  });

  Proveedor copyWith({
    String? codigo,
    String? nombre,
    String? nit,
    String? telefono,
    String? direccion,
    bool? isSynced,
  }) {
    return Proveedor(
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
