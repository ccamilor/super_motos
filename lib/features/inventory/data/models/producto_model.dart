import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/producto.dart';

part 'producto_model.g.dart';

@collection
class ProductoModel {
  Id id = Isar.autoIncrement;
  late String nombre;
  late double precio;
  String? imagenUrl;
  late bool isOriginal;
  late String motosCompatibles;
  late int stockMinimo;

  Producto toDomain() {
    return Producto(
      id: id,
      nombre: nombre,
      precio: precio,
      imagenUrl: imagenUrl,
      isOriginal: isOriginal,
      motosCompatibles: motosCompatibles,
      stockMinimo: stockMinimo,
    );
  }

  static ProductoModel fromDomain(Producto domain) {
    return ProductoModel()
      ..id = domain.id
      ..nombre = domain.nombre
      ..precio = domain.precio
      ..imagenUrl = domain.imagenUrl
      ..isOriginal = domain.isOriginal
      ..motosCompatibles = domain.motosCompatibles
      ..stockMinimo = domain.stockMinimo;
  }
}
