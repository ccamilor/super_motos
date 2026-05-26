import 'package:isar/isar.dart';

part 'historial_precios_model.g.dart';

@collection
class HistorialPreciosModel {
  Id id = Isar.autoIncrement;
  late String productoId;
  late String proveedorId;
  late double precioCompra;
  late DateTime fechaRegistro;
}
