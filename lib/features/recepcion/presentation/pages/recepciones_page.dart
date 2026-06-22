import 'package:flutter/material.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_io.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/recepcion/presentation/pages/recepcion_detail_page.dart';
import 'package:super_motos/features/recepcion/presentation/pages/recepcion_form_page.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_io.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class RecepcionesPage extends StatefulWidget {
  const RecepcionesPage({super.key, this.proveedorId});

  final String? proveedorId;

  @override
  State<RecepcionesPage> createState() => _RecepcionesPageState();
}

class _RecepcionesPageState extends State<RecepcionesPage> {
  final RecepcionRepository _recepcionRepo = createRecepcionRepository();
  final ProveedoresRepository _proveedoresRepo = createProveedoresRepository();

  final TextEditingController _searchController = TextEditingController();

  List<Recepcion> _recepciones = [];
  Map<String, Proveedor> _proveedoresByCodigo = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
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
    _recepcionRepo.loadAll().then((recepciones) {
      if (mounted) setState(() => _recepciones = recepciones);
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recepciones = widget.proveedorId != null
          ? await _recepcionRepo.loadByProveedor(widget.proveedorId!)
          : await _recepcionRepo.loadAll();
      final proveedores = await _proveedoresRepo.loadAll();
      if (!mounted) return;
      setState(() {
        _recepciones = recepciones;
        _proveedoresByCodigo = {for (final p in proveedores) p.codigo: p};
      });
    } catch (e) {
      debugPrint('Error al cargar recepciones: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecepcionFormPage(proveedorId: widget.proveedorId),
      ),
    );
    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _openDetail(Recepcion recepcion) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecepcionDetailPage(recepcion: recepcion),
      ),
    );
    if (changed == true) {
      await _loadData();
    }
  }

  List<Recepcion> get _filteredRecepciones {
    if (_searchQuery.isEmpty) return _recepciones;
    final q = _searchQuery.toLowerCase();
    return _recepciones.where((r) {
      final proveedor = _proveedoresByCodigo[r.proveedorId];
      final matchProveedor = proveedor != null && proveedor.nombre.toLowerCase().contains(q);
      final matchRemito = r.nroRemito?.toLowerCase().contains(q) ?? false;
      final matchFecha = _formatFecha(r.fecha).toLowerCase().contains(q);
      return matchProveedor || matchRemito || matchFecha;
    }).toList();
  }

  String _formatFecha(DateTime f) {
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }

  String _formatCOP(double precio) {
    final valorEntero = precio.toInt();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formateado = valorEntero.toString().replaceAllMapped(reg, (match) => '${match[1]}.');
    return '\$ $formateado COP';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredRecepciones;

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
            Icon(Icons.inventory_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.proveedorId != null
                    ? 'Recepciones de ${_proveedoresByCodigo[widget.proveedorId]?.nombre ?? widget.proveedorId}'
                    : 'Recepciones',
                style: const TextStyle(fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_recepciones.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_recepciones.length}',
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
                  hintText: 'Buscar por proveedor, remito o fecha...',
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
                            return _buildRecepcionCard(filtered[index], colorScheme);
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
        label: const Text('Nueva', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRecepcionCard(Recepcion recepcion, ColorScheme colorScheme) {
    final proveedor = _proveedoresByCodigo[recepcion.proveedorId];
    final proveedorNombre = proveedor?.nombre ?? 'Proveedor #${recepcion.proveedorId}';

    return InkWell(
      onTap: () => _openDetail(recepcion),
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
                      proveedorNombre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    SyncStatusBadge(isSynced: recepcion.isSynced, compact: true),
                  ],
                ),
                if (recepcion.nroRemito != null && recepcion.nroRemito!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      recepcion.nroRemito!,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatFecha(recepcion.fecha),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (recepcion.observaciones != null && recepcion.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                recepcion.observaciones!,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${recepcion.detalles.length} ${recepcion.detalles.length == 1 ? "linea" : "lineas"}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  _formatCOP(recepcion.total),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
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
          Icon(Icons.inventory_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            _recepciones.isEmpty ? 'No hay recepciones registradas' : 'Sin resultados para "$_searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_recepciones.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Toca "Nueva" para registrar la primera',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
