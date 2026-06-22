import 'package:flutter/material.dart';

import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';
import 'package:super_motos/features/customers/presentation/pages/cliente_form_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesRepository _repository = createClientesRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> _clientes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClientes();
    SyncService.instance.syncResultNotifier.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    SyncService.instance.syncResultNotifier.removeListener(_onSyncChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSyncChanged() {
    if (!mounted) return;
    _repository.loadAll().then((clientes) {
      if (mounted) setState(() => _clientes = clientes);
    });
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await _repository.loadAll();
      if (!mounted) return;
      setState(() => _clientes = clientes);
    } catch (e) {
      debugPrint('Error al cargar clientes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm({Cliente? cliente}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ClienteFormPage(cliente: cliente),
      ),
    );
    if (saved == true) {
      await _loadClientes();
    }
  }

  Future<void> _deleteCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cliente', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Estas seguro de eliminar a "${cliente.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repository.delete(cliente.codigo);
      if (!mounted) return;
      setState(() {
        _clientes = _clientes.where((c) => c.codigo != cliente.codigo).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            'Cliente "${cliente.nombre}" eliminado',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Error al eliminar: $e'),
        ),
      );
    }
  }

  List<Cliente> get _filteredClientes {
    if (_searchQuery.isEmpty) return _clientes;
    final q = _searchQuery.toLowerCase();
    return _clientes.where((c) {
      final matchNombre = c.nombre.toLowerCase().contains(q);
      final matchNit = c.identificadorFiscal.toLowerCase().contains(q);
      return matchNombre || matchNit;
    }).toList();
  }

  Color _estadoColor(EstadoCuenta estado, ColorScheme scheme) {
    switch (estado) {
      case EstadoCuenta.activo:
        return scheme.primary;
      case EstadoCuenta.suspendido:
        return Colors.white54;
      case EstadoCuenta.sinCredito:
        return scheme.error;
    }
  }

  String _estadoLabel(EstadoCuenta estado) {
    switch (estado) {
      case EstadoCuenta.activo:
        return 'ACTIVO';
      case EstadoCuenta.suspendido:
        return 'SUSPENDIDO';
      case EstadoCuenta.sinCredito:
        return 'SIN CREDITO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredClientes;

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncStateIndicator(),
          ),
        ],
        title: Row(
          children: [
            Icon(Icons.people_outline_rounded, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text('Clientes',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (_clientes.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_clientes.length}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o NIT...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : filtered.isEmpty
                      ? _emptyState(colorScheme)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildClienteCard(filtered[index], colorScheme);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildClienteCard(Cliente cliente, ColorScheme colorScheme) {
    final excedeLimite = cliente.saldoPendiente > cliente.limiteCredito;
    final borderColor = excedeLimite
        ? colorScheme.error.withValues(alpha: 0.4)
        : colorScheme.outlineVariant.withValues(alpha: 0.3);

    return InkWell(
      onTap: () => _openForm(cliente: cliente),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      cliente.nombre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SyncStatusBadge(isSynced: cliente.isSynced, compact: true),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _estadoColor(cliente.estadoCuenta, colorScheme).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _estadoColor(cliente.estadoCuenta, colorScheme).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        _estadoLabel(cliente.estadoCuenta),
                        style: TextStyle(
                          color: _estadoColor(cliente.estadoCuenta, colorScheme),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                      onPressed: () => _deleteCliente(cliente),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'NIT: ${cliente.identificadorFiscal}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              cliente.direccion,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: excedeLimite
                    ? colorScheme.error.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SALDO PENDIENTE', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        formatCOP(cliente.saldoPendiente),
                        style: TextStyle(
                          color: excedeLimite ? colorScheme.error : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('LIMITE CREDITO', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        formatCOP(cliente.limiteCredito),
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            _clientes.isEmpty ? 'No hay clientes' : 'Sin resultados para "$_searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_clientes.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Toca "Nuevo" para crear el primero',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
