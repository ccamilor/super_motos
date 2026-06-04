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

class DevolucionDetailPage extends StatefulWidget {
  const DevolucionDetailPage({super.key, required this.devolucion});

  final Devolucion devolucion;

  @override
  State<DevolucionDetailPage> createState() => _DevolucionDetailPageState();
}

class _DevolucionDetailPageState extends State<DevolucionDetailPage> {
  final DevolucionesRepository _devolucionesRepo = createDevolucionesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  ProductoModel? _producto;
  bool _isDeleting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final productos = (await _inventoryRepo.loadInventory()).productos;
      final pid = int.tryParse(widget.devolucion.productoId);
      if (!mounted) return;
      setState(() {
        _producto = pid == null
            ? null
            : productos.firstWhere(
                (p) => p.id == pid,
                orElse: () => productos.isNotEmpty
                    ? productos.first
                    : ProductoModel()
                      ..nombre = 'Producto #${widget.devolucion.productoId}'
                      ..precio = 0
                      ..isOriginal = false
                      ..motosCompatibles = ''
                      ..stockMinimo = 0,
              );
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
        title: const Text('Eliminar devolucion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Estas seguro de eliminar la devolucion #${widget.devolucion.id}? El stock NO se descontara automaticamente.',
        ),
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
      await _devolucionesRepo.delete(widget.devolucion.id);
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
    final d = widget.devolucion;

    return Scaffold(
      appBar: AppBar(
        title: Text('Devolucion #${d.id}', style: const TextStyle(fontWeight: FontWeight.w900)),
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
                    _buildHeader(d, colorScheme),
                    const SizedBox(height: 24),
                    Text('DETALLES', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    _buildInfoRow('Factura origen', '#${d.facturaId}', colorScheme),
                    const SizedBox(height: 8),
                    _buildInfoRow('Producto', _producto?.nombre ?? '#${d.productoId}', colorScheme),
                    const SizedBox(height: 8),
                    _buildInfoRow('Cantidad devuelta', '+${d.cantidad}', colorScheme, valueColor: colorScheme.primary),
                    const SizedBox(height: 8),
                    _buildInfoRow('Canasta destino', d.numeroCanastaDestino, colorScheme),
                    const SizedBox(height: 8),
                    _buildInfoRow('Motivo', d.motivo, colorScheme, multiline: true),
                    const SizedBox(height: 24),
                    _buildFooter(d, colorScheme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(Devolucion d, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Devolucion', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text('#${d.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                const Text('STOCK REPUESTO', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text('+${d.cantidad}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, {bool multiline = false, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: multiline ? null : 1,
              overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Devolucion d, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _footerRow('Fecha', _formatFechaCompleta(d.fechaDevolucion), colorScheme),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado sync', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              SyncStatusBadge(isSynced: d.isSynced),
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
        Text(
          value,
          style: TextStyle(
            color: highlight ? colorScheme.secondary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
