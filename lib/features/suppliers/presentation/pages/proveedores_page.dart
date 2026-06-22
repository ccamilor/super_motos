import 'package:flutter/material.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_io.dart';
import 'package:super_motos/features/recepcion/presentation/pages/recepciones_page.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_io.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';
import 'package:super_motos/features/suppliers/presentation/pages/proveedor_form_page.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  final ProveedoresRepository _proveedoresRepo = createProveedoresRepository();
  final RecepcionRepository _recepcionRepo = createRecepcionRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Proveedor> _proveedores = [];
  Map<String, int> _recepcionCountByProveedor = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProveedores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProveedores() async {
    setState(() => _isLoading = true);
    try {
      final proveedores = await _proveedoresRepo.loadAll();
      final recepciones = await _recepcionRepo.loadAll();
      if (!mounted) return;
      setState(() {
        _proveedores = proveedores;
        _recepcionCountByProveedor = {};
        for (final r in recepciones) {
          _recepcionCountByProveedor[r.proveedorId] = (_recepcionCountByProveedor[r.proveedorId] ?? 0) + 1;
        }
      });
    } catch (e) {
      debugPrint('Error al cargar proveedores: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm({Proveedor? proveedor}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProveedorFormPage(proveedor: proveedor),
      ),
    );
    if (saved == true) {
      await _loadProveedores();
    }
  }

  Future<void> _deleteProveedor(Proveedor proveedor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proveedor', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Estas seguro de eliminar a "${proveedor.nombre}"?'),
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
      await _proveedoresRepo.delete(proveedor.codigo);
      if (!mounted) return;
      setState(() {
        _proveedores = _proveedores.where((p) => p.codigo != proveedor.codigo).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            'Proveedor "${proveedor.nombre}" eliminado',
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

  List<Proveedor> get _filteredProveedores {
    if (_searchQuery.isEmpty) return _proveedores;
    final q = _searchQuery.toLowerCase();
    return _proveedores.where((p) {
      return p.nombre.toLowerCase().contains(q) || p.nit.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredProveedores;

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
            Icon(Icons.local_shipping_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Proveedores', style: TextStyle(fontWeight: FontWeight.w900)),
            if (_proveedores.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_proveedores.length}',
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
                            return _buildProveedorCard(filtered[index], colorScheme);
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

  Widget _buildProveedorCard(Proveedor proveedor, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _openForm(proveedor: proveedor),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          proveedor.nombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SyncStatusBadge(isSynced: proveedor.isSynced, compact: true),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                  onPressed: () => _deleteProveedor(proveedor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'NIT: ${proveedor.nit}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              proveedor.direccion,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  proveedor.telefono,
                  style: TextStyle(color: colorScheme.primary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecepcionesPage(proveedorId: proveedor.codigo),
                ),
              ),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_outlined, size: 14, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Recepciones',
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_recepcionCountByProveedor[proveedor.codigo] ?? 0}',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 10, color: colorScheme.secondary),
                  ],
                ),
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
          Icon(Icons.local_shipping_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            _proveedores.isEmpty ? 'No hay proveedores' : 'Sin resultados para "$_searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_proveedores.isEmpty) ...[
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