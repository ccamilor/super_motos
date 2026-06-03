class Proveedor {
  final int id;
  final String nombre;
  final String nit;
  final String telefono;
  final String direccion;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.telefono,
    required this.direccion,
  });

  Proveedor copyWith({
    int? id,
    String? nombre,
    String? nit,
    String? telefono,
    String? direccion,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
    );
  }
}