import 'package:flutter/material.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository.dart';
import 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/recepcion/data/repositories/recepcion_repository_io.dart';
import 'package:super_motos/features/recepcion/domain/entities/detalle_recepcion.dart';
import 'package:super_motos/features/recepcion/domain/entities/recepcion.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_io.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class RecepcionDetailPage extends StatefulWidget {
  const RecepcionDetailPage({super.key, required this.recepcion});

  final Recepcion recepcion;

  @override
  State<RecepcionDetailPage> createState() => _RecepcionDetailPageState();
}

class _RecepcionDetailPageState extends State<RecepcionDetailPage> {
  final RecepcionRepository _recepcionRepo = createRecepcionRepository();
  final ProveedoresRepository _proveedoresRepo = createProveedoresRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  Proveedor? _proveedor;
  Map<String, ProductoModel> _productosByCodigo = {};
  bool _isDeleting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final proveedores = await _proveedoresRepo.loadAll();
      final productos = (await _inventoryRepo.loadInventory()).productos;
      if (!mounted) return;
      setState(() {
        _proveedor = proveedores.firstWhere(
          (p) => p.codigo == widget.recepcion.proveedorId,
          orElse: () => Proveedor(
            codigo: widget.recepcion.proveedorId,
            nombre: 'Proveedor #${widget.recepcion.proveedorId}',
            nit: '-',
            telefono: '-',
            direccion: '-',
          ),
        );
        _productosByCodigo = {for (final p in productos) p.codigo: p};
      });
    } catch (e) {
      debugPrint('Error al cargar detalle: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar recepcion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Estas seguro de eliminar la recepcion ${widget.recepcion.codigo}? El stock NO se revertira automaticamente.'),
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

    setState(() => _isDeleting = true);
    try {
      await _recepcionRepo.delete(widget.recepcion.codigo);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Error al eliminar: $e'),
        ),
      );
      setState(() => _isDeleting = false);
    }
  }

  String _formatFechaCompleta(DateTime f) {
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${f.day.toString().padLeft(2, '0')} ${meses[f.month - 1]} ${f.year}, ${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final r = widget.recepcion;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recepcion ${r.codigo}', style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: _isDeleting ? null : _eliminar,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(r, colorScheme),
                    const SizedBox(height: 24),
                    Text('DETALLES', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    ...r.detalles.map((d) => _buildLineaCard(d, colorScheme)),
                    const SizedBox(height: 24),
                    _buildFooter(r, colorScheme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(Recepcion r, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_proveedor?.nombre ?? 'Proveedor #${r.proveedorId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('NIT: ${_proveedor?.nit ?? "-"}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              if (r.nroRemito != null && r.nroRemito!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    r.nroRemito!,
                    style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text(formatCOP(r.total), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaCard(DetalleRecepcion d, ColorScheme colorScheme) {
    final producto = _productosByCodigo[d.productoId];
    final nombre = producto?.nombre ?? 'Producto #${d.productoId}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cantidad', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('${d.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio unit.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(formatCOP(d.precioUnitario), style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(formatCOP(d.subtotal), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _destinoColor(d.destino, colorScheme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_outlined, size: 14, color: _destinoColor(d.destino, colorScheme)),
                const SizedBox(width: 4),
                Text(
                  _destinoLabel(d),
                  style: TextStyle(
                    color: _destinoColor(d.destino, colorScheme),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _destinoColor(String destino, ColorScheme colorScheme) {
    switch (destino) {
      case 'camion':
        return colorScheme.primary;
      case 'bodega':
        return colorScheme.secondary;
      case 'split':
        return Colors.amber;
      default:
        return Colors.white54;
    }
  }

  String _destinoLabel(DetalleRecepcion d) {
    switch (d.destino) {
      case 'camion':
        return 'Camion: ${d.cantidad} und';
      case 'bodega':
        return 'Bodega: ${d.cantidad} und';
      case 'split':
        return 'Split: Camion ${d.cantidadCamion} + Bodega ${d.cantidadBodega}';
      default:
        return d.destino;
    }
  }

  Widget _buildFooter(Recepcion r, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _footerRow('Fecha', _formatFechaCompleta(r.fecha), colorScheme),
          if (r.observaciones != null && r.observaciones!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _footerRow('Observaciones', r.observaciones!, colorScheme),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado sync', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              SyncStatusBadge(isSynced: r.isSynced),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerRow(String label, String value, ColorScheme colorScheme, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: highlight ? colorScheme.secondary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
