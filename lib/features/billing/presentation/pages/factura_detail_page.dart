import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';

class FacturaDetailPage extends StatefulWidget {
  const FacturaDetailPage({super.key, required this.factura});

  final Factura factura;

  @override
  State<FacturaDetailPage> createState() => _FacturaDetailPageState();
}

class _FacturaDetailPageState extends State<FacturaDetailPage> {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final ClientesRepository _clientesRepo = createClientesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  Cliente? _cliente;
  Map<String, ProductoModel> _productosById = {};
  List<DetalleFactura> _detallesEdit = [];
  bool _isDeleting = false;
  bool _isSaving = false;
  bool _isLoading = true;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clientes = await _clientesRepo.loadAll();
      final productos = (await _inventoryRepo.loadInventory()).productos;
      if (!mounted) return;
      setState(() {
        _cliente = clientes.firstWhere(
          (c) => c.codigo == widget.factura.clienteId,
          orElse: () => Cliente(
            codigo: widget.factura.clienteId,
            nombre: 'Cliente #${widget.factura.clienteId}',
            identificadorFiscal: '-',
            direccion: '-',
            limiteCredito: 0,
            saldoPendiente: 0,
            estadoCuenta: EstadoCuenta.activo,
          ),
        );
        _productosById = {for (final p in productos) p.codigo: p};
        _detallesEdit = List<DetalleFactura>.from(widget.factura.detalles);
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
        title: const Text('Eliminar factura', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Estas seguro de eliminar la factura ${widget.factura.codigo}? El stock NO se repondra automaticamente.'),
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
      await _facturasRepo.delete(widget.factura.codigo);
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

  void _updatePrecio(int index, String raw) {
    final cleaned = raw.replaceAll('.', '').replaceAll(',', '.');
    final n = double.tryParse(cleaned);
    if (n == null || n < 0) return;
    setState(() {
      final d = _detallesEdit[index];
      _detallesEdit[index] = d.copyWith(
        precioUnitario: n,
        subtotal: n * d.cantidad,
      );
      _isDirty = true;
    });
  }

  double get _totalEdit => _detallesEdit.fold(0.0, (sum, d) => sum + d.subtotal);

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Descartar cambios?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tienes cambios sin guardar. Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Salir sin guardar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _guardarCambios() async {
    setState(() => _isSaving = true);
    try {
      final facturaEditada = widget.factura.copyWith(
        detalles: _detallesEdit,
        total: _totalEdit,
        isSynced: false,
      );
      await _facturasRepo.update(facturaEditada);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade700,
          content: const Text(
            'Cambios guardados — Pendiente de sincronizacion',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Error al guardar cambios: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Color _tipoPagoColor(TipoPago tipo, ColorScheme scheme) {
    switch (tipo) {
      case TipoPago.contado:
        return scheme.primary;
      case TipoPago.credito:
        return scheme.secondary;
      case TipoPago.transferencia:
        return Colors.lightBlueAccent;
    }
  }

  String _tipoPagoLabel(TipoPago tipo) {
    switch (tipo) {
      case TipoPago.contado:
        return 'CONTADO';
      case TipoPago.credito:
        return 'CREDITO';
      case TipoPago.transferencia:
        return 'TRANSFERENCIA';
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
    final f = widget.factura;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Factura ${f.codigo}', style: const TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else if (_isDirty)
              TextButton(
                onPressed: _isSaving ? null : _guardarCambios,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Guardar',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
                      _buildHeader(f, colorScheme),
                      const SizedBox(height: 24),
                      Text('DETALLES', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      ..._detallesEdit.asMap().entries.map(
                            (e) => _buildLineaCard(e.key, e.value, colorScheme),
                          ),
                      const SizedBox(height: 24),
                      _buildFooter(f, colorScheme),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Factura f, ColorScheme colorScheme) {
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
                    Text(_cliente?.nombre ?? 'Cliente #${f.clienteId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 2),
                    Text('NIT: ${_cliente?.identificadorFiscal ?? "-"}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _tipoPagoColor(f.tipoPago, colorScheme).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _tipoPagoColor(f.tipoPago, colorScheme).withValues(alpha: 0.4)),
                ),
                child: Text(
                  _tipoPagoLabel(f.tipoPago),
                  style: TextStyle(color: _tipoPagoColor(f.tipoPago, colorScheme), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                ),
              ),
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
                Text(formatCOP(_totalEdit), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaCard(int index, DetalleFactura d, ColorScheme colorScheme) {
    final producto = _productosById[d.productoId];
    final nombre = producto?.nombre ?? 'Producto #${d.productoId}';
    final precioModificado = producto != null && (d.precioUnitario - producto.precio).abs() > 0.01;
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
          Row(
            children: [
              Expanded(
                child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              if (precioModificado)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'PRECIO MODIFICADO',
                    style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
            ],
          ),
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
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Precio unit.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixText: '\$ ',
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(text: d.precioUnitario.toStringAsFixed(0))
                        ..selection = TextSelection.collapsed(offset: d.precioUnitario.toStringAsFixed(0).length),
                      onSubmitted: (v) => _updatePrecio(index, v),
                      onChanged: (v) => _updatePrecio(index, v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
          if (precioModificado) ...[
            const SizedBox(height: 4),
            Text(
              'Original: ${formatCOP(producto.precio)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(Factura f, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _footerRow('Fecha', _formatFechaCompleta(f.fecha), colorScheme),
          const SizedBox(height: 8),
          _footerRow('Vendedor', '#${f.vendedorId}', colorScheme),
          if (f.latitudVenta != null && f.longitudVenta != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ubicacion', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.location_on, color: colorScheme.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${f.latitudVenta!.toStringAsFixed(4)}, ${f.longitudVenta!.toStringAsFixed(4)}',
                      style: TextStyle(color: colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado sync', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              SyncStatusBadge(isSynced: f.isSynced),
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
