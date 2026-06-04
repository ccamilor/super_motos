class Proveedor {
  final int id;
  final String nombre;
  final String nit;
  final String telefono;
  final String direccion;
  final bool isSynced;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.telefono,
    required this.direccion,
    this.isSynced = false,
  });

  Proveedor copyWith({
    int? id,
    String? nombre,
    String? nit,
    String? telefono,
    String? direccion,
    bool? isSynced,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}