import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_motos/core/utils/code_generator.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
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

class RecepcionFormPage extends StatefulWidget {
  const RecepcionFormPage({super.key, this.proveedorId});

  final String? proveedorId;

  @override
  State<RecepcionFormPage> createState() => _RecepcionFormPageState();
}

class _RecepcionFormPageState extends State<RecepcionFormPage> {
  final RecepcionRepository _recepcionRepo = createRecepcionRepository();
  final ProveedoresRepository _proveedoresRepo = createProveedoresRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  final TextEditingController _nroRemitoCtrl = TextEditingController();
  final TextEditingController _observacionesCtrl = TextEditingController();

  List<Proveedor> _proveedores = [];
  List<ProductoModel> _productos = [];
  Proveedor? _proveedorSeleccionado;
  DateTime _fecha = DateTime.now();
  final List<DetalleRecepcion> _lineas = [];

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
    _nroRemitoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final proveedores = await _proveedoresRepo.loadAll();
      final snapshot = await _inventoryRepo.loadInventory();
      if (!mounted) return;
      setState(() {
        _proveedores = proveedores;
        _productos = snapshot.productos;
        if (widget.proveedorId != null) {
          _proveedorSeleccionado = proveedores.firstWhere(
            (p) => p.codigo == widget.proveedorId,
            orElse: () => proveedores.first,
          );
        }
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
        title: const Text('Descartar recepcion?', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _openLineForm() async {
    final result = await showModalBottomSheet<DetalleRecepcion>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LineFormSheet(
        productos: _productos,
      ),
    );
    if (result != null) {
      setState(() {
        _lineas.add(result);
        _isDirty = true;
      });
    }
  }

  void _removeLinea(int index) {
    setState(() {
      _lineas.removeAt(index);
      _isDirty = true;
    });
  }

  String? _validarAntesDeGuardar() {
    if (_proveedorSeleccionado == null) return 'Selecciona un proveedor';
    if (_lineas.isEmpty) return 'Agrega al menos una linea';

    for (final l in _lineas) {
      if (l.destino == 'split') {
        final sum = (l.cantidadCamion ?? 0) + (l.cantidadBodega ?? 0);
        if (sum != l.cantidad) {
          return 'Split invalido para ${_productoNombre(l.productoId)}: camion (${l.cantidadCamion}) + bodega (${l.cantidadBodega}) debe ser igual a ${l.cantidad}';
        }
      }
    }
    return null;
  }

  String _productoNombre(String productoId) {
    final p = _productos.firstWhere(
      (p) => p.codigo == productoId,
      orElse: () => ProductoModel()..nombre = productoId,
    );
    return p.nombre;
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
    try {
      final recepcion = Recepcion(
        codigo: await CodeGenerator.next('REC'),
        proveedorId: _proveedorSeleccionado!.codigo,
        fecha: _fecha,
        nroRemito: _nroRemitoCtrl.text.trim().isEmpty ? null : _nroRemitoCtrl.text.trim(),
        observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
        detalles: _lineas,
      );

      await _recepcionRepo.create(recepcion);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade700,
          content: const Text(
            'Recepción guardada — Pendiente de sincronización',
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
          content: Text('Error al guardar la recepcion: $e'),
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
          title: const Text('Nueva recepcion', style: TextStyle(fontWeight: FontWeight.w900)),
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
                            _sectionLabel('Proveedor', colorScheme),
                            const SizedBox(height: 8),
                            _buildProveedorPicker(colorScheme),
                            const SizedBox(height: 24),
                            _sectionLabel('Cabecera', colorScheme),
                            const SizedBox(height: 8),
                            _buildFechaPicker(colorScheme),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nroRemitoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nro. Remito / Factura',
                                hintText: 'Ej: RM-1001',
                                prefixIcon: Icon(Icons.receipt_long_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _observacionesCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Observaciones',
                                hintText: 'Notas adicionales...',
                                prefixIcon: Icon(Icons.notes_outlined),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _sectionLabel('Lineas', colorScheme),
                            const SizedBox(height: 8),
                            ..._lineas.asMap().entries.map(
                                  (e) => _buildLineaCard(e.key, e.value, colorScheme),
                                ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _openLineForm,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar linea'),
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

  Widget _buildProveedorPicker(ColorScheme colorScheme) {
    return DropdownButtonFormField<Proveedor>(
      initialValue: _proveedorSeleccionado,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Seleccionar proveedor',
        prefixIcon: Icon(Icons.business_outlined),
      ),
      items: _proveedores
          .map((p) => DropdownMenuItem<Proveedor>(
                value: p,
                child: Text('${p.nombre}  (NIT ${p.nit})'),
              ))
          .toList(),
      onChanged: (p) {
        if (p != null) {
          setState(() {
            _proveedorSeleccionado = p;
            _isDirty = true;
          });
        }
      },
      validator: (v) => v == null ? 'Selecciona un proveedor' : null,
    );
  }

  Widget _buildFechaPicker(ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            _fecha = picked;
            _isDirty = true;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text('${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}'),
      ),
    );
  }

  Widget _buildLineaCard(int index, DetalleRecepcion linea, ColorScheme colorScheme) {
    final productoNombre = _productoNombre(linea.productoId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productoNombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatCOP(linea.precioUnitario)} c/u  x  ${linea.cantidad}  =  ${formatCOP(linea.subtotal)}',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _destinoColor(linea.destino, colorScheme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_outlined, size: 14, color: _destinoColor(linea.destino, colorScheme)),
                const SizedBox(width: 4),
                Text(
                  _destinoLabel(linea),
                  style: TextStyle(
                    color: _destinoColor(linea.destino, colorScheme),
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

  String _destinoLabel(DetalleRecepcion linea) {
    switch (linea.destino) {
      case 'camion':
        return 'Camion: ${linea.cantidad} und';
      case 'bodega':
        return 'Bodega: ${linea.cantidad} und';
      case 'split':
        return 'Split: Camion ${linea.cantidadCamion} + Bodega ${linea.cantidadBodega}';
      default:
        return linea.destino;
    }
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
}

class _LineFormSheet extends StatefulWidget {
  const _LineFormSheet({required this.productos});

  final List<ProductoModel> productos;

  @override
  State<_LineFormSheet> createState() => _LineFormSheetState();
}

class _LineFormSheetState extends State<_LineFormSheet> {
  final _formKey = GlobalKey<FormState>();
  ProductoModel? _productoSeleccionado;
  final TextEditingController _cantidadCtrl = TextEditingController(text: '1');
  final TextEditingController _precioCtrl = TextEditingController();
  String _destino = 'camion';
  final TextEditingController _cantCamionCtrl = TextEditingController();
  final TextEditingController _cantBodegaCtrl = TextEditingController();

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    _cantCamionCtrl.dispose();
    _cantBodegaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final productosDisponibles = widget.productos.where((p) => p.codigo.isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const Text('Agregar linea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductoModel>(
                initialValue: _productoSeleccionado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: productosDisponibles
                    .map((p) => DropdownMenuItem<ProductoModel>(
                          value: p,
                          child: Text(p.nombre),
                        ))
                    .toList(),
                onChanged: (p) => setState(() => _productoSeleccionado = p),
                validator: (v) => v == null ? 'Selecciona un producto' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 1) return 'Cantidad invalida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Precio unitario (COP)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Precio invalido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _sectionLabel('Destino', colorScheme),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'camion', label: Text('Camion'), icon: Icon(Icons.local_shipping_outlined)),
                  ButtonSegment(value: 'bodega', label: Text('Bodega'), icon: Icon(Icons.warehouse_outlined)),
                  ButtonSegment(value: 'split', label: Text('Split'), icon: Icon(Icons.call_split)),
                ],
                selected: {_destino},
                onSelectionChanged: (s) => setState(() => _destino = s.first),
              ),
              if (_destino == 'split') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cantCamionCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Camion',
                          isDense: true,
                        ),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 1) return 'Invalido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cantBodegaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Bodega',
                          isDense: true,
                        ),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 1) return 'Invalido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    final cantidad = int.parse(_cantidadCtrl.text.trim());
                    final precio = double.parse(_precioCtrl.text.trim());

                    int? cantCamion;
                    int? cantBodega;
                    if (_destino == 'split') {
                      cantCamion = int.tryParse(_cantCamionCtrl.text.trim());
                      cantBodega = int.tryParse(_cantBodegaCtrl.text.trim());
                      if (cantCamion == null || cantBodega == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa las cantidades de camion y bodega')),
                        );
                        return;
                      }
                      if (cantCamion + cantBodega != cantidad) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Camion ($cantCamion) + Bodega ($cantBodega) debe ser igual a $cantidad')),
                        );
                        return;
                      }
                    }

                    final detalle = DetalleRecepcion(
                      productoId: _productoSeleccionado!.codigo,
                      cantidad: cantidad,
                      precioUnitario: precio,
                      destino: _destino,
                      cantidadCamion: cantCamion,
                      cantidadBodega: cantBodega,
                    );
                    Navigator.of(context).pop(detalle);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Agregar linea', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
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
}
