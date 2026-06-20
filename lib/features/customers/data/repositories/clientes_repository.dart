import 'package:super_motos/features/customers/domain/entities/cliente.dart';

abstract class ClientesRepository {
  Future<List<Cliente>> loadAll();
  Future<Cliente> create(Cliente cliente);
  Future<Cliente> update(Cliente cliente);
  Future<void> delete(String codigo);
}
