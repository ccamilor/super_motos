import 'package:flutter/material.dart';

import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/returns/data/repositories/devoluciones_repository_io.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';
import 'package:super_motos/features/returns/presentation/pages/devolucion_detail_page.dart';
import 'package:super_motos/features/returns/presentation/pages/devolucion_form_page.dart';

class DevolucionesPage extends StatefulWidget {
  const DevolucionesPage({super.key});

  @override
  State<DevolucionesPage> createState() => _DevolucionesPageState();
}

class _DevolucionesPageState extends State<DevolucionesPage> {
  final DevolucionesRepository _devolucionesRepo = createDevolucionesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  final TextEditingController _searchController = TextEditingController();

  List<Devolucion> _devoluciones = [];
  Map<String, ProductoModel> _productosByStringId = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final devoluciones = await _devolucionesRepo.loadAll();
      final productos = (await _inventoryRepo.loadInventory()).productos;
      if (!mounted) return;
      setState(() {
        _devoluciones = devoluciones;
        _productosByStringId = {
          for (final p in productos) p.codigo: p,
        };
      });
    } catch (e) {
      debugPrint('Error al cargar devoluciones: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const DevolucionFormPage()),
    );
    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _openDetail(Devolucion devolucion) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DevolucionDetailPage(devolucion: devolucion),
      ),
    );
    if (changed == true) {
      await _loadData();
    }
  }

  List<Devolucion> get _filteredDevoluciones {
    if (_searchQuery.isEmpty) return _devoluciones;
    final q = _searchQuery.toLowerCase();
    return _devoluciones.where((d) {
      return d.facturaId.toLowerCase().contains(q) ||
          d.motivo.toLowerCase().contains(q) ||
          d.canastaDestino.toLowerCase().contains(q);
    }).toList();
  }

  String _formatFecha(DateTime f) {
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredDevoluciones;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.replay_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Devoluciones', style: TextStyle(fontWeight: FontWeight.w900)),
            if (_devoluciones.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_devoluciones.length}',
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
                  hintText: 'Buscar por factura, motivo o canasta...',
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
                            return _buildDevolucionCard(filtered[index], colorScheme);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Devolucion', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDevolucionCard(Devolucion devolucion, ColorScheme colorScheme) {
    final producto = _productosByStringId[devolucion.productoId];
    final productoNombre = producto?.nombre ?? 'Producto #${devolucion.productoId}';

    return InkWell(
      onTap: () => _openDetail(devolucion),
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
                Row(
                  children: [
                    Text(
                      'Devolucion ${devolucion.codigo}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SyncStatusBadge(isSynced: devolucion.isSynced, compact: true),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Factura #${devolucion.facturaId}',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              productoNombre,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              devolucion.motivo,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      _formatFecha(devolucion.fechaDevolucion),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.inbox_outlined, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Canasta ${devolucion.canastaDestino}',
                      style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${devolucion.cantidad}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
          Icon(Icons.replay_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            _devoluciones.isEmpty
                ? 'No hay devoluciones registradas'
                : 'Sin resultados para "$_searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_devoluciones.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Toca "Nueva Devolucion" para registrar la primera',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
