import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_motos/core/constants/vendedor.dart';
import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
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

class FacturaFormPage extends StatefulWidget {
  const FacturaFormPage({super.key});

  @override
  State<FacturaFormPage> createState() => _FacturaFormPageState();
}

class _LineItem {
  final ProductoModel producto;
  int cantidad;
  final double precioUnitario;

  _LineItem({
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;

  DetalleFactura toDetalle() {
    return DetalleFactura(
      productoId: producto.id,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }
}

class _FacturaFormPageState extends State<FacturaFormPage> {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final ClientesRepository _clientesRepo = createClientesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  List<Cliente> _clientes = [];
  List<ProductoModel> _productos = [];
  Map<int, int> _stockCamionByProducto = {};

  Cliente? _clienteSeleccionado;
  final List<_LineItem> _lineas = [];
  TipoPago _tipoPago = TipoPago.contado;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await _clientesRepo.loadAll();
      final snapshot = await _inventoryRepo.loadInventory();
      if (!mounted) return;
      setState(() {
        _clientes = clientes;
        _productos = snapshot.productos;
        _stockCamionByProducto = {
          for (final c in snapshot.camion) c.productoId: c.cantidad,
        };
      });
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _total => _lineas.fold(0.0, (sum, l) => sum + l.subtotal);

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Descartar venta?', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _openProductPicker() async {
    final picked = await showModalBottomSheet<ProductoModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ProductPickerSheet(
        productos: _productos,
        stockById: _stockCamionByProducto,
      ),
    );
    if (picked == null) return;

    final stock = _stockCamionByProducto[picked.id] ?? 0;
    setState(() {
      _lineas.add(_LineItem(
        producto: picked,
        cantidad: 1,
        precioUnitario: picked.precio,
      ));
      _isDirty = true;
    });
    if (stock <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('"${picked.nombre}" no tiene stock en el camion. La venta fallara al guardar.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeLinea(int index) {
    setState(() {
      _lineas.removeAt(index);
      _isDirty = true;
    });
  }

  void _updateCantidad(int index, String raw) {
    final n = int.tryParse(raw);
    if (n == null || n < 1) return;
    setState(() {
      _lineas[index].cantidad = n;
      _isDirty = true;
    });
  }

  String? _validarAntesDeGuardar() {
    if (_clienteSeleccionado == null) return 'Selecciona un cliente';
    if (_lineas.isEmpty) return 'Agrega al menos un producto';

    for (final l in _lineas) {
      final stock = _stockCamionByProducto[l.producto.id] ?? 0;
      if (l.cantidad > stock) {
        return 'Stock insuficiente para ${l.producto.nombre} (disponible: $stock, requerido: ${l.cantidad})';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validarAntesDeGuardar();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(error),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final stockWarnings = <String>[];
    try {
      final factura = Factura(
        numeroFactura: 0,
        clienteId: _clienteSeleccionado!.id,
        vendedorId: kVendedorPorDefecto,
        fecha: DateTime.now(),
        total: _total,
        tipoPago: _tipoPago,
        detalles: _lineas.map((l) => l.toDetalle()).toList(),
      );

      await _facturasRepo.create(factura);

      for (final l in _lineas) {
        try {
          await _inventoryRepo.decrementCamionStock(l.producto.id, l.cantidad);
          _stockCamionByProducto[l.producto.id] =
              (_stockCamionByProducto[l.producto.id] ?? 0) - l.cantidad;
        } catch (e) {
          stockWarnings.add('${l.producto.nombre}: ${e.toString().split('\n').first}');
        }
      }

      if (!mounted) return;
      if (stockWarnings.isEmpty) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 6),
            content: Text(
              'Venta guardada, pero el stock no se desconto: ${stockWarnings.join("; ")}',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Error al guardar la venta: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          title: const Text('Nueva venta', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _save,
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
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('Cliente', colorScheme),
                            const SizedBox(height: 8),
                            _buildClientePicker(colorScheme),
                            if (_clienteSeleccionado != null) ...[
                              const SizedBox(height: 8),
                              _buildClienteResumen(_clienteSeleccionado!, colorScheme),
                            ],
                            const SizedBox(height: 24),
                            _sectionLabel('Productos', colorScheme),
                            const SizedBox(height: 8),
                            ..._lineas.asMap().entries.map(
                                  (e) => _buildLineaRow(e.key, e.value, colorScheme),
                                ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _openProductPicker,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar producto'),
                            ),
                            const SizedBox(height: 24),
                            _sectionLabel('Pago', colorScheme),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<TipoPago>(
                              initialValue: _tipoPago,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de pago',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              items: TipoPago.values
                                  .map((e) => DropdownMenuItem<TipoPago>(
                                        value: e,
                                        child: Text(_tipoPagoLabel(e)),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _tipoPago = v;
                                    _isDirty = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildTotalFooter(colorScheme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme colorScheme) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildClientePicker(ColorScheme colorScheme) {
    return DropdownButtonFormField<Cliente>(
      initialValue: _clienteSeleccionado,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Seleccionar cliente',
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: _clientes
          .map((c) => DropdownMenuItem<Cliente>(
                value: c,
                child: Text('${c.nombre}  (NIT ${c.identificadorFiscal})'),
              ))
          .toList(),
      onChanged: (c) {
        if (c != null) {
          setState(() {
            _clienteSeleccionado = c;
            _isDirty = true;
          });
        }
      },
      validator: (v) => v == null ? 'Selecciona un cliente' : null,
    );
  }

  Widget _buildClienteResumen(Cliente c, ColorScheme colorScheme) {
    final excede = c.saldoPendiente > c.limiteCredito;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIT: ${c.identificadorFiscal}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 2),
          Text(c.direccion, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saldo: ${formatCOP(c.saldoPendiente)}',
                  style: TextStyle(color: excede ? colorScheme.error : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Limite: ${formatCOP(c.limiteCredito)}',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineaRow(int index, _LineItem linea, ColorScheme colorScheme) {
    final stock = _stockCamionByProducto[linea.producto.id] ?? 0;
    final stockInsuficiente = linea.cantidad > stock;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stockInsuficiente
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(linea.producto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${formatCOP(linea.precioUnitario)} c/u  -  stock: $stock',
                        style: TextStyle(
                          color: stock == 0
                              ? colorScheme.error
                              : (stockInsuficiente ? colorScheme.error : Colors.white54),
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () => _removeLinea(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Cant',
                    isDense: true,
                  ),
                  controller: TextEditingController(text: linea.cantidad.toString())
                    ..selection = TextSelection.collapsed(offset: linea.cantidad.toString().length),
                  onSubmitted: (v) => _updateCantidad(index, v),
                  onChanged: (v) => _updateCantidad(index, v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(formatCOP(linea.subtotal),
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('TOTAL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
          Text(
            formatCOP(_total),
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ],
      ),
    );
  }

  String _tipoPagoLabel(TipoPago tipo) {
    switch (tipo) {
      case TipoPago.contado:
        return 'Contado';
      case TipoPago.credito:
        return 'Credito';
      case TipoPago.transferencia:
        return 'Transferencia';
    }
  }
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({
    required this.productos,
    required this.stockById,
  });

  final List<ProductoModel> productos;
  final Map<int, int> stockById;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final q = _query.toLowerCase();
    final filtered = q.isEmpty
        ? widget.productos
        : widget.productos.where((p) =>
            p.nombre.toLowerCase().contains(q) ||
            p.motosCompatibles.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Seleccionar producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o moto...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Sin resultados'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final stock = widget.stockById[p.id] ?? 0;
                          return InkWell(
                            onTap: () => Navigator.of(context).pop(p),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: stock == 0
                                      ? colorScheme.error.withValues(alpha: 0.4)
                                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(p.motosCompatibles, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(formatCOP(p.precio), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text('stock: $stock', style: TextStyle(color: stock == 0 ? colorScheme.error : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
