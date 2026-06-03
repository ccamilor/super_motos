import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/returns/data/repositories/devoluciones_repository_io.dart';
import 'package:super_motos/features/returns/domain/entities/devolucion.dart';

const List<String> _motivosComunes = [
  'Defecto de fabrica',
  'Producto incorrecto',
  'Dano en transporte',
  'Cambio de opinion',
];
const String _motivoOtro = 'Otro';

class DevolucionFormPage extends StatefulWidget {
  const DevolucionFormPage({super.key});

  @override
  State<DevolucionFormPage> createState() => _DevolucionFormPageState();
}

class _DevolucionFormPageState extends State<DevolucionFormPage> {
  final _formKey = GlobalKey<FormState>();

  final FacturasRepository _facturasRepo = createFacturasRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();
  final DevolucionesRepository _devolucionesRepo = createDevolucionesRepository();

  final TextEditingController _cantidadCtrl = TextEditingController(text: '1');
  final TextEditingController _canastaCtrl = TextEditingController();
  final TextEditingController _motivoTextoCtrl = TextEditingController();

  List<Factura> _facturas = [];
  Map<int, ProductoModel> _productosById = {};

  Factura? _facturaSeleccionada;
  ProductoModel? _productoSeleccionado;
  DetalleFactura? _lineaOriginal;
  String _motivoSeleccionado = _motivosComunes.first;
  bool _otroSeleccionado = false;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _canastaCtrl.dispose();
    _motivoTextoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final facturas = await _facturasRepo.loadAll();
      final productos = (await _inventoryRepo.loadInventory()).productos;
      if (!mounted) return;
      setState(() {
        _facturas = facturas;
        _productosById = {for (final p in productos) p.id: p};
      });
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ProductoModel> _productosEnFactura(Factura f) {
    final ids = f.detalles.map((d) => d.productoId).toSet();
    return ids
        .map((id) => _productosById[id])
        .whereType<ProductoModel>()
        .toList();
  }

  void _onFacturaChanged(Factura? f) {
    setState(() {
      _facturaSeleccionada = f;
      _productoSeleccionado = null;
      _lineaOriginal = null;
      _isDirty = true;
    });
  }

  void _onProductoChanged(ProductoModel? p) {
    if (p == null || _facturaSeleccionada == null) {
      setState(() {
        _productoSeleccionado = null;
        _lineaOriginal = null;
        _isDirty = true;
      });
      return;
    }
    final linea = _facturaSeleccionada!.detalles.firstWhere(
      (d) => d.productoId == p.id,
      orElse: () => const DetalleFactura(productoId: 0, cantidad: 0, precioUnitario: 0, subtotal: 0),
    );
    setState(() {
      _productoSeleccionado = p;
      _lineaOriginal = linea.productoId == 0 ? null : linea;
      _isDirty = true;
    });
  }

  void _onMotivoChanged(String? value) {
    if (value == null) return;
    setState(() {
      _motivoSeleccionado = value;
      _otroSeleccionado = value == _motivoOtro;
      _isDirty = true;
    });
  }

  String? _validarCantidad(String? raw) {
    final n = int.tryParse(raw?.trim() ?? '');
    if (n == null) return 'Cantidad invalida';
    if (n < 1) return 'La cantidad debe ser al menos 1';
    if (_lineaOriginal != null && n > _lineaOriginal!.cantidad) {
      return 'La factura solo vendio ${_lineaOriginal!.cantidad} unidades';
    }
    return null;
  }

  String? _validarAntesDeGuardar() {
    if (_facturaSeleccionada == null) return 'Selecciona la factura de origen';
    if (_productoSeleccionado == null) return 'Selecciona el producto devuelto';
    if (_canastaCtrl.text.trim().isEmpty) return 'Indica la canasta de destino';
    final cantidad = int.tryParse(_cantidadCtrl.text.trim());
    if (cantidad == null || cantidad < 1) return 'Cantidad invalida';
    if (_lineaOriginal != null && cantidad > _lineaOriginal!.cantidad) {
      return 'No puedes devolver mas de ${_lineaOriginal!.cantidad} unidades (facturado)';
    }
    if (_otroSeleccionado && _motivoTextoCtrl.text.trim().isEmpty) {
      return 'Escribe el motivo en el campo de texto';
    }
    return null;
  }

  String _motivoFinal() {
    if (_otroSeleccionado) return _motivoTextoCtrl.text.trim();
    return _motivoSeleccionado;
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Descartar devolucion?', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

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
      final cantidad = int.parse(_cantidadCtrl.text.trim());
      final devolucion = Devolucion(
        id: 0,
        facturaId: _facturaSeleccionada!.numeroFactura.toString(),
        productoId: _productoSeleccionado!.id.toString(),
        cantidad: cantidad,
        numeroCanastaDestino: _canastaCtrl.text.trim(),
        fechaDevolucion: DateTime.now(),
        motivo: _motivoFinal(),
      );

      await _devolucionesRepo.create(devolucion);

      try {
        await _inventoryRepo.incrementCamionStock(_productoSeleccionado!.id, cantidad);
      } catch (e) {
        stockWarnings.add(e.toString().split('\n').first);
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
              'Devolucion guardada, pero no se repuso el stock: ${stockWarnings.join("; ")}',
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
          content: Text('Error al guardar: $e'),
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
          title: const Text('Nueva devolucion', style: TextStyle(fontWeight: FontWeight.w900)),
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
                child: Form(
                  key: _formKey,
                  onChanged: () {
                    if (!_isDirty) setState(() => _isDirty = true);
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Factura de origen', colorScheme),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Factura>(
                          initialValue: _facturaSeleccionada,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Factura',
                            prefixIcon: Icon(Icons.receipt_long_outlined),
                          ),
                          items: _facturas
                              .map((f) => DropdownMenuItem<Factura>(
                                    value: f,
                                    child: Text(
                                      'Factura #${f.numeroFactura}  -  ${_formatFecha(f.fecha)}',
                                    ),
                                  ))
                              .toList(),
                          onChanged: _onFacturaChanged,
                          validator: (v) => v == null ? 'Selecciona una factura' : null,
                        ),
                        if (_facturaSeleccionada != null) ...[
                          const SizedBox(height: 16),
                          _sectionLabel('Producto devuelto', colorScheme),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ProductoModel>(
                            initialValue: _productoSeleccionado,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Producto',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            items: _productosEnFactura(_facturaSeleccionada!)
                                .map((p) {
                              final linea = _facturaSeleccionada!.detalles
                                  .firstWhere((d) => d.productoId == p.id);
                              return DropdownMenuItem<ProductoModel>(
                                value: p,
                                child: Text(
                                  '${p.nombre}  (facturado: ${linea.cantidad})',
                                ),
                              );
                            }).toList(),
                            onChanged: _onProductoChanged,
                            validator: (v) => v == null ? 'Selecciona un producto' : null,
                          ),
                        ],
                        if (_productoSeleccionado != null) ...[
                          const SizedBox(height: 16),
                          _sectionLabel('Detalle', colorScheme),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cantidadCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Cantidad devuelta',
                              hintText: '1',
                              prefixIcon: const Icon(Icons.numbers),
                              helperText: _lineaOriginal != null
                                  ? 'Maximo: ${_lineaOriginal!.cantidad} (lo facturado)'
                                  : null,
                            ),
                            validator: _validarCantidad,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _canastaCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Canasta de destino',
                              hintText: 'Ej: A2, B1, C3',
                              prefixIcon: Icon(Icons.inbox_outlined),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Indica la canasta' : null,
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('Motivo', colorScheme),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _motivoSeleccionado,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Motivo',
                              prefixIcon: Icon(Icons.help_outline),
                            ),
                            items: [..._motivosComunes, _motivoOtro]
                                .map((m) => DropdownMenuItem<String>(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                            onChanged: _onMotivoChanged,
                          ),
                          if (_otroSeleccionado) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _motivoTextoCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Describe el motivo',
                                hintText: 'Cuentanos que ocurrio...',
                                prefixIcon: Icon(Icons.edit_outlined),
                              ),
                              validator: (v) => _otroSeleccionado && (v == null || v.trim().isEmpty)
                                  ? 'Escribe el motivo'
                                  : null,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: _buildFooter(colorScheme),
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    final cantidad = int.tryParse(_cantidadCtrl.text.trim());
    final mostrar = _productoSeleccionado != null && (cantidad ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              mostrar
                  ? 'Se repondran $cantidad ${cantidad == 1 ? "unidad" : "unidades"} de ${_productoSeleccionado!.nombre} al stock del camion'
                  : 'Selecciona factura y producto para ver el resumen',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          if (mostrar) ...[
            const SizedBox(width: 8),
            Text(
              '+$cantidad',
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ],
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

  String _formatFecha(DateTime f) {
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }
}
