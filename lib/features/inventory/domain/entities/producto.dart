class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String? imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
  });
}
