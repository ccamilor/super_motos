import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'inventory_file_reader_stub.dart'
    if (dart.library.io) 'inventory_file_reader_io.dart';
import 'inventory_file_writer_stub.dart'
    if (dart.library.io) 'inventory_file_writer_io.dart'
    if (dart.library.js_interop) 'inventory_file_writer_web.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';
import 'package:super_motos/features/inventory/presentation/pages/producto_form_page.dart';
import 'package:super_motos/features/inventory/presentation/widgets/csv_preview_modal.dart';
import 'package:super_motos/features/sync/presentation/widgets/sync_badge.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/core/utils/import_progress.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final InventoryRepository _repository = createInventoryRepository();

  List<ProductoModel> _productos = [];
  List<InventarioCamionModel> _camion = [];
  List<InventarioBodegaModel> _bodega = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _syncButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _repository.loadInventory();
      if (!mounted) return;
      setState(() {
        _productos = snapshot.productos;
        _camion = snapshot.camion;
        _bodega = snapshot.bodega;
      });
    } catch (e) {
      debugPrint('Error al cargar inventario: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCSV(ColorScheme colorScheme) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb,
      );

      if (result == null ||
          (kIsWeb
              ? result.files.single.bytes == null
              : result.files.single.path == null)) {
        return;
      }

      final input = kIsWeb
          ? String.fromCharCodes(result.files.single.bytes!)
          : await readPickedFileAsString(result.files.single);

      final existingCodes = _productos.map((p) => p.codigo).toSet();

      if (!mounted) return;

      final previewResult = await showDialog<CsvPreviewResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => CsvPreviewModal(
          csvContent: input,
          existingProductCodes: existingCodes,
        ),
      );

      if (previewResult == null) return;

      // Show progress dialog
      final cancelToken = CancelToken();
      final progressController = StreamController<ImportProgress>();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Importando CSV...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<ImportProgress>(
                  stream: _createProgressStream(input, progressController, cancelToken),
                  builder: (context, snapshot) {
                    final progress = snapshot.data;
                    if (progress == null) return const SizedBox.shrink();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          value: progress.total > 0 ? progress.progress : 0,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          progress.currentItem != null
                              ? 'Procesando: ${progress.currentItem}'
                              : 'Preparando...',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress.processed} / ${progress.total} productos',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  cancelToken.isCancelled
                      ? 'Cancelando...'
                      : 'Importando productos...',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!cancelToken.isCancelled) {
                    cancelToken.cancel();
                  }
                },
                child: Text(cancelToken.isCancelled ? 'Cancelando...' : 'Cancelar'),
              ),
            ],
          ),
        ),
      );

      try {
        setState(() => _isLoading = true);

        final snapshot = await _repository.importCsv(input);
        if (!mounted) return;

        setState(() {
          _productos = snapshot.productos;
          _camion = snapshot.camion;
          _bodega = snapshot.bodega;
        });

        if (mounted) {
          _showPostImportReport(colorScheme, previewResult);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 4),
              content: Text(
                'ERROR al importar archivo: $e',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      } finally {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 4),
            content: Text(
              'ERROR al importar archivo: $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Stream<ImportProgress> _createProgressStream(
    String csvContent,
    StreamController<ImportProgress> controller,
    CancelToken cancelToken,
  ) {
    _repository.importCsv(
      csvContent,
      onProgress: (progress) {
        controller.add(progress);
      },
      cancelToken: cancelToken,
    ).then((_) {
      controller.close();
    }).catchError((error) {
      controller.addError(error);
      controller.close();
    });

    return controller.stream;
  }

  Future<void> _exportCSV(ColorScheme colorScheme) async {
    try {
      setState(() => _isLoading = true);

      final csvContent = await _repository.exportCsv();
      if (!mounted) return;

      final fileName = 'inventario_${DateTime.now().millisecondsSinceEpoch}.csv';
      final saved = await saveCsvContent(csvContent, fileName);

      if (!mounted) return;

      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 3),
            content: Text(
              'Inventario exportado correctamente',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 4),
            content: Text(
              'Error al exportar: $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showPostImportReport(ColorScheme colorScheme, CsvPreviewResult previewResult) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Importación completada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _buildReportRow(
                  colorScheme: colorScheme,
                  icon: Icons.add_circle_outline,
                  label: 'Productos creados',
                  value: '${previewResult.newProducts}',
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                _buildReportRow(
                  colorScheme: colorScheme,
                  icon: Icons.update,
                  label: 'Productos actualizados',
                  value: '${previewResult.existingProducts}',
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 8),
                _buildReportRow(
                  colorScheme: colorScheme,
                  icon: Icons.list_alt,
                  label: 'Total procesados',
                  value: '${previewResult.totalRows}',
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm({InventoryEntry? entry}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductoFormPage(entry: entry)),
    );
    if (result == true) {
      _loadInventory();
    }
  }

  Future<void> _triggerSync() async {
    setState(() => _syncButtonLoading = true);
    await SyncService.instance.forcePushAll();
    await SyncService.instance.pullAll();
    if (mounted) {
      setState(() => _syncButtonLoading = false);
    }
  }

  Future<bool> _confirmDelete(InventoryEntry entry) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${entry.nombre}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatCOP(double precio) {
    final valorEntero = precio.toInt();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formateado = valorEntero.toString().replaceAllMapped(
      reg,
      (match) => '${match[1]}.',
    );
    return '\$ $formateado COP';
  }

  List<ProductoModel> get _filteredProductos {
    if (_searchQuery.isEmpty) return _productos;
    final q = _searchQuery.toLowerCase();
    return _productos.where((p) {
      final nameMatches = p.nombre.toLowerCase().contains(q);
      final compatibilityMatches = p.motosCompatibles.toLowerCase().contains(q);
      return nameMatches || compatibilityMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Manejo de Inventario',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncStateIndicator(),
          ),
          SyncBadge(
            child: IconButton(
              onPressed: _syncButtonLoading ? null : _triggerSync,
              icon: _syncButtonLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: _syncButtonLoading ? 'Sincronizando...' : 'Sincronizar ahora',
            ),
          ),
          IconButton(
            onPressed: () => _importCSV(colorScheme),
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Cargar CSV',
          ),
          IconButton(
            onPressed: () => _exportCSV(colorScheme),
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Producto'),
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: false,
                    floating: true,
                    snap: true,
                    toolbarHeight: 48,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        color: colorScheme.surface,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Buscar por repuesto o modelo de moto...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.primary,
                            ),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarHeaderDelegate(
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.local_shipping_outlined, size: 18),
                            text: 'Mi Camión',
                          ),
                          Tab(
                            icon: Icon(Icons.warehouse_outlined, size: 18),
                            text: 'Bodega Central',
                          ),
                          Tab(
                            icon: Icon(Icons.analytics_outlined, size: 18),
                            text: 'Inventario Total',
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildCamionTab(colorScheme),
                  _buildBodegaTab(colorScheme),
                  _buildTotalTab(colorScheme),
                ],
              ),
            ),
    );
  }

  Widget _buildCamionTab(ColorScheme colorScheme) {
    final filtered = _filteredProductos;
    if (filtered.isEmpty) return _emptyState(colorScheme);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final producto = filtered[index];
        final camion = _camion.firstWhere(
          (item) => item.productoId == producto.codigo,
          orElse: () => InventarioCamionModel()
            ..productoId = producto.codigo
            ..cantidad = 0
            ..canastaId = '0',
        );
        final bajoStock = camion.cantidad < producto.stockMinimo;

        return _inventoryCard(
          title: producto.nombre,
          subtitle: producto.motosCompatibles,
          price: _formatCOP(producto.precio),
          badge: producto.isOriginal ? 'ORIGINAL' : 'GENÉRICO',
          badgeColor: producto.isOriginal
              ? colorScheme.primary
              : Colors.white54,
          alertText: bajoStock
              ? 'STOCK BAJO (Min: ${producto.stockMinimo})'
              : null,
          leftLabel: 'Canasta ${camion.canastaId}',
          leftValue: '${camion.cantidad} und',
          rightLabel: 'Disponible',
          rightValue: '${camion.cantidad} und',
          rightValueColor: bajoStock ? colorScheme.error : colorScheme.primary,
          borderColor: bajoStock
              ? colorScheme.error.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildBodegaTab(ColorScheme colorScheme) {
    final filtered = _filteredProductos;
    if (filtered.isEmpty) return _emptyState(colorScheme);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final producto = filtered[index];
        final bodega = _bodega.firstWhere(
          (item) => item.productoId == producto.codigo,
          orElse: () => InventarioBodegaModel()
            ..productoId = producto.codigo
            ..cantidad = 0,
        );

        return _inventoryCard(
          title: producto.nombre,
          subtitle: producto.motosCompatibles,
          price: _formatCOP(producto.precio),
          badge: producto.isOriginal ? 'ORIGINAL' : 'GENÉRICO',
          badgeColor: producto.isOriginal
              ? colorScheme.primary
              : Colors.white54,
          alertText: 'ALMACÉN CENTRAL',
          leftLabel: 'Sujeto a despacho',
          leftValue: '${bodega.cantidad} und',
          rightLabel: 'Stock',
          rightValue: '${bodega.cantidad} und',
          rightValueColor: colorScheme.primary,
          borderColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildTotalTab(ColorScheme colorScheme) {
    final filtered = _filteredProductos;
    if (filtered.isEmpty) return _emptyState(colorScheme);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final producto = filtered[index];
        final camion = _camion.firstWhere(
          (item) => item.productoId == producto.codigo,
          orElse: () => InventarioCamionModel()
            ..productoId = producto.codigo
            ..cantidad = 0
            ..canastaId = '0',
        );
        final bodega = _bodega.firstWhere(
          (item) => item.productoId == producto.codigo,
          orElse: () => InventarioBodegaModel()
            ..productoId = producto.codigo
            ..cantidad = 0,
        );

        final stockTotal = camion.cantidad + bodega.cantidad;
        final sugerir =
            camion.cantidad < producto.stockMinimo && bodega.cantidad > 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sugerir
                  ? colorScheme.secondary.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (producto.isOriginal
                                        ? colorScheme.primary
                                        : Colors.white54)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            producto.isOriginal ? 'ORIGINAL' : 'GENÉRICO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: producto.isOriginal
                                  ? colorScheme.primary
                                  : Colors.white54,
                            ),
                          ),
                        ),
                        if (camion.cantidad < producto.stockMinimo) ...[
                          const SizedBox(width: 6),
                          Text(
                            'STOCK BAJO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      producto.motosCompatibles,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${camion.cantidad} und',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: camion.cantidad < producto.stockMinimo
                                ? colorScheme.error
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${bodega.cantidad} und',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatCOP(producto.precio),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$stockTotal und',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _openForm(
                            entry: InventoryEntry(
                              codigo: producto.codigo,
                              nombre: producto.nombre,
                              precio: producto.precio,
                              isOriginal: producto.isOriginal,
                              motosCompatibles: producto.motosCompatibles,
                              stockMinimo: producto.stockMinimo,
                              cantidadCamion: camion.cantidad,
                              canastaId: camion.canastaId,
                              cantidadBodega: bodega.cantidad,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () async {
                            final confirm = await _confirmDelete(
                              InventoryEntry(
                                codigo: producto.codigo,
                                nombre: producto.nombre,
                                precio: producto.precio,
                                isOriginal: producto.isOriginal,
                                motosCompatibles: producto.motosCompatibles,
                                stockMinimo: producto.stockMinimo,
                                cantidadCamion: camion.cantidad,
                                canastaId: camion.canastaId,
                                cantidadBodega: bodega.cantidad,
                              ),
                            );
                            if (confirm) {
                              await _repository.deleteProduct(producto.codigo);
                              _loadInventory();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(ColorScheme colorScheme) {
    return Center(
      child: Text(
        'Sin resultados para "$_searchQuery"',
        style: TextStyle(color: colorScheme.error),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _inventoryCard({
    required String title,
    required String subtitle,
    required String price,
    required String badge,
    required Color badgeColor,
    required String? alertText,
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    required Color rightValueColor,
    required Color borderColor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    if (alertText != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        alertText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: alertText == 'ALMACÉN CENTRAL'
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  leftLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                Text(
                  leftValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  rightLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                  textAlign: TextAlign.end,
                ),
                Text(
                  rightValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rightValueColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
