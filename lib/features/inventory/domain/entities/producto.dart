class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String? imagenUrl;
  final bool isOriginal;
  final String motosCompatibles;
  final int stockMinimo;
  final bool isSynced;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
    required this.isOriginal,
    required this.motosCompatibles,
    required this.stockMinimo,
    this.isSynced = false,
  });
}
