import 'package:isar/isar.dart';
import 'package:super_motos/features/inventory/domain/entities/producto.dart';

part 'producto_model.g.dart';

@collection
class ProductoModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String codigo = '';
  late String nombre;
  late double precio;
  String? imagenUrl;
  late bool isOriginal;
  late String motosCompatibles;
  late int stockMinimo;
  bool isSynced = false;

  Producto toDomain() {
    return Producto(
      codigo: codigo,
      nombre: nombre,
      precio: precio,
      imagenUrl: imagenUrl,
      isOriginal: isOriginal,
      motosCompatibles: motosCompatibles,
      stockMinimo: stockMinimo,
      isSynced: isSynced,
    );
  }

  static ProductoModel fromDomain(Producto domain) {
    return ProductoModel()
      ..codigo = domain.codigo
      ..nombre = domain.nombre
      ..precio = domain.precio
      ..imagenUrl = domain.imagenUrl
      ..isOriginal = domain.isOriginal
      ..motosCompatibles = domain.motosCompatibles
      ..stockMinimo = domain.stockMinimo
      ..isSynced = domain.isSynced;
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'precio': precio,
      'imagen_url': imagenUrl,
      'is_original': isOriginal,
      'motos_compatibles': motosCompatibles,
      'stock_minimo': stockMinimo,
      'is_synced': isSynced,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
