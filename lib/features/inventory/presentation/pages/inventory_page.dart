import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'inventory_file_reader_stub.dart'
    if (dart.library.io) 'inventory_file_reader_io.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/inventory/data/models/inventario_bodega_model.dart';
import 'package:super_motos/features/inventory/data/models/inventario_camion_model.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final InventoryRepository _repository = createInventoryRepository();

  List<ProductoModel> _productos = [];
  List<InventarioCamionModel> _camion = [];
  List<InventarioBodegaModel> _bodega = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

      if (result == null || (kIsWeb ? result.files.single.bytes == null : result.files.single.path == null)) {
        return;
      }

      setState(() => _isLoading = true);

      final input = kIsWeb
          ? String.fromCharCodes(result.files.single.bytes!)
          : await readPickedFileAsString(result.files.single);

      final snapshot = await _repository.importCsv(input);
      if (!mounted) return;

      setState(() {
        _productos = snapshot.productos;
        _camion = snapshot.camion;
        _bodega = snapshot.bodega;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 3),
            content: const Text(
              'EXITO: Inventario cargado y guardado satisfactoriamente.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              'ERROR al importar archivo: $e',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatCOP(double precio) {
    final valorEntero = precio.toInt();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formateado = valorEntero.toString().replaceAllMapped(reg, (match) => '${match[1]}.');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manejo de Inventario', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping_outlined, size: 20), text: 'Mi CamiÃ³n'),
            Tab(icon: Icon(Icons.warehouse_outlined, size: 20), text: 'Bodega Central'),
            Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: 'Inventario Total'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por repuesto o modelo de moto...',
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
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCamionTab(colorScheme),
                        _buildBodegaTab(colorScheme),
                        _buildTotalTab(colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCamionTab(ColorScheme colorScheme) {
    final filtered = _filteredProductos;
    if (filtered.isEmpty) return _emptyState(colorScheme);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final producto = filtered[index];
        final camion = _camion.firstWhere(
          (item) => item.productoId == producto.id,
          orElse: () => InventarioCamionModel()
            ..productoId = producto.id
            ..cantidad = 0
            ..numeroCanasta = 0,
        );
        final bajoStock = camion.cantidad < producto.stockMinimo;

        return _inventoryCard(
          title: producto.nombre,
          subtitle: producto.motosCompatibles,
          price: _formatCOP(producto.precio),
          badge: producto.isOriginal ? 'ORIGINAL' : 'GENÃ‰RICO',
          badgeColor: producto.isOriginal ? colorScheme.primary : Colors.white54,
          alertText: bajoStock ? 'STOCK BAJO (Min: ${producto.stockMinimo})' : null,
          leftLabel: 'Canasta #${camion.numeroCanasta}',
          leftValue: '${camion.cantidad} und',
          rightLabel: 'Disponible',
          rightValue: '${camion.cantidad} und',
          rightValueColor: bajoStock ? colorScheme.error : colorScheme.primary,
          borderColor: bajoStock ? colorScheme.error.withValues(alpha: 0.35) : colorScheme.outlineVariant.withValues(alpha: 0.3),
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildBodegaTab(ColorScheme colorScheme) {
    final filtered = _filteredProductos;
    if (filtered.isEmpty) return _emptyState(colorScheme);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final producto = filtered[index];
        final bodega = _bodega.firstWhere(
          (item) => item.productoId == producto.id,
          orElse: () => InventarioBodegaModel()
            ..productoId = producto.id
            ..cantidad = 0,
        );

        return _inventoryCard(
          title: producto.nombre,
          subtitle: producto.motosCompatibles,
          price: _formatCOP(producto.precio),
          badge: producto.isOriginal ? 'ORIGINAL' : 'GENÃ‰RICO',
          badgeColor: producto.isOriginal ? colorScheme.primary : Colors.white54,
          alertText: 'ALMACÃ‰N CENTRAL',
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _importCSV(colorScheme),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Cargar CSV'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final producto = filtered[index];
              final camion = _camion.firstWhere(
                (item) => item.productoId == producto.id,
                orElse: () => InventarioCamionModel()
                  ..productoId = producto.id
                  ..cantidad = 0
                  ..numeroCanasta = 0,
              );
              final bodega = _bodega.firstWhere(
                (item) => item.productoId == producto.id,
                orElse: () => InventarioBodegaModel()
                  ..productoId = producto.id
                  ..cantidad = 0,
              );

              final stockTotal = camion.cantidad + bodega.cantidad;
              final sugerir = camion.cantidad < producto.stockMinimo && bodega.cantidad > 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sugerir ? colorScheme.secondary.withValues(alpha: 0.4) : colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          producto.isOriginal ? 'ORIGINAL' : 'GENÃ‰RICO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: producto.isOriginal ? colorScheme.primary : Colors.white54,
                          ),
                        ),
                        if (sugerir)
                          Text(
                            'REABASTECIMIENTO SUGERIDO',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(producto.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(producto.motosCompatibles, style: const TextStyle(color: Colors.white54)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('En mi CamiÃ³n', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('${camion.cantidad} und', style: TextStyle(fontWeight: FontWeight.bold, color: camion.cantidad < producto.stockMinimo ? colorScheme.error : Colors.white)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bodega Central', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('${bodega.cantidad} und', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('STOCK TOTAL DISPONIBLE', style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold)),
                        Text('$stockTotal unidades', style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
              ),
              if (alertText != null)
                Text(
                  alertText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: alertText == 'ALMACÃ‰N CENTRAL' ? colorScheme.primary : colorScheme.error),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leftLabel, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    const SizedBox(height: 4),
                    Text(leftValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rightLabel, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    const SizedBox(height: 4),
                    Text(rightValue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: rightValueColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

