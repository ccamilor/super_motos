import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_motos/core/utils/code_generator.dart';
import 'package:super_motos/features/inventory/data/models/producto_model.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/recepcion/presentation/pages/recepcion_form_page.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/historial_precios_repository_io.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository.dart';
import 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/suppliers/data/repositories/proveedores_repository_io.dart';
import 'package:super_motos/features/suppliers/domain/entities/historial_precio.dart';
import 'package:super_motos/features/suppliers/domain/entities/proveedor.dart';

class ProveedorFormPage extends StatefulWidget {
  const ProveedorFormPage({super.key, this.proveedor});

  final Proveedor? proveedor;

  @override
  State<ProveedorFormPage> createState() => _ProveedorFormPageState();
}

class _ProveedorFormPageState extends State<ProveedorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ProveedoresRepository _proveedoresRepo = createProveedoresRepository();
  final HistorialPreciosRepository _historialRepo = createHistorialPreciosRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _direccionCtrl;

  Map<String, ProductoModel> _productosById = {};
  List<_PrecioEntry> _precioEntries = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false;
  bool _historialExpanded = false;

  bool get _isEdit => widget.proveedor != null;

  @override
  void initState() {
    super.initState();
    final p = widget.proveedor;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _nitCtrl = TextEditingController(text: p?.nit ?? '');
    _telefonoCtrl = TextEditingController(text: p?.telefono ?? '');
    _direccionCtrl = TextEditingController(text: p?.direccion ?? '');
    _loadData();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final productos = (await _inventoryRepo.loadInventory()).productos;
      if (!mounted) return;
      _productosById = {for (final p in productos) p.codigo: p};

      if (_isEdit) {
        final historial = await _historialRepo.loadByProveedorId(widget.proveedor!.codigo);
        if (!mounted) return;
        _precioEntries = historial
            .where((h) => h.productoId.isNotEmpty)
            .map((h) => _PrecioEntry(
                  productoId: h.productoId,
                  precio: h.precioCompra,
                  fecha: h.fechaRegistro,
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final nuevo = Proveedor(
        codigo: widget.proveedor?.codigo ?? await CodeGenerator.next('PROV'),
        nombre: _nombreCtrl.text.trim(),
        nit: _nitCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
      );

      final saved = _isEdit
          ? await _proveedoresRepo.update(nuevo)
          : await _proveedoresRepo.create(nuevo);

      for (final entry in _precioEntries) {
        if (entry.productoId.isEmpty) continue;
        await _historialRepo.create(HistorialPrecio(
          codigo: await CodeGenerator.next('PVHS'),
          productoId: entry.productoId,
          proveedorId: saved.codigo,
          precioCompra: entry.precio,
          fechaRegistro: entry.fecha,
        ));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade700,
          content: Text(
            _isEdit
                ? 'Proveedor actualizado — Pendiente de sincronización'
                : 'Proveedor creado — Pendiente de sincronización',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          content: Text('Error al guardar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addPrecioEntry() {
    setState(() {
      _precioEntries.add(_PrecioEntry(
        productoId: _productosById.keys.first,
        precio: 0,
        fecha: DateTime.now(),
      ));
      _isDirty = true;
      _historialExpanded = true;
    });
  }

  void _removePrecioEntry(int index) {
    setState(() {
      _precioEntries.removeAt(index);
      _isDirty = true;
    });
  }

  Widget _buildHistorialSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _historialExpanded = !_historialExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historial de Precios (${_precioEntries.length})',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _historialExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        if (_historialExpanded) ...[
          const SizedBox(height: 12),
          if (_precioEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Sin precios registrados',
                    style: TextStyle(color: colorScheme.outlineVariant),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_precioEntries.length, (i) {
              final entry = _precioEntries[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _productosById.containsKey(entry.productoId)
                            ? entry.productoId
                            : (_productosById.keys.isNotEmpty
                                ? _productosById.keys.first
                                : null),
                        decoration: const InputDecoration(
                          labelText: 'Producto',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _productosById.values.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.codigo,
                            child: Text(p.nombre, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _precioEntries[i] = entry.copyWith(productoId: v);
                              _isDirty = true;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        initialValue: entry.precio > 0 ? entry.precio.toStringAsFixed(0) : '',
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          isDense: true,
                          prefixText: '\$ ',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          final precio = double.tryParse(v) ?? 0;
                          setState(() {
                            _precioEntries[i] = entry.copyWith(precio: precio);
                            _isDirty = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.error, size: 18),
                      onPressed: () => _removePrecioEntry(i),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addPrecioEntry,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar precio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
            ),
          ),
        ],
      ],
    );
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
          title: Text(
            _isEdit ? 'Editar proveedor' : 'Nuevo proveedor',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
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
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    onChanged: () {
                      if (!_isDirty) setState(() => _isDirty = true);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Datos del proveedor', colorScheme),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nombreCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            hintText: 'Ej: Repuestos Moto JC',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nitCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'NIT',
                            hintText: 'Solo digitos',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El NIT es obligatorio';
                            if (v.trim().length < 6) return 'El NIT debe tener al menos 6 digitos';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Telefono',
                            hintText: '3001234567',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'El telefono es obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _direccionCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Direccion',
                            hintText: 'Calle / Carrera, Ciudad',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'La direccion es obligatoria' : null,
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('Historial de precios', colorScheme),
                        const SizedBox(height: 8),
                        _buildHistorialSection(colorScheme),
                        const SizedBox(height: 24),
                        _sectionLabel('Recepciones', colorScheme),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecepcionFormPage(
                                    proveedorId: widget.proveedor?.codigo,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.inventory_outlined, size: 18),
                            label: const Text('Registrar recepcion'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.secondary,
                              side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
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

class _PrecioEntry {
  final String productoId;
  final double precio;
  final DateTime fecha;

  _PrecioEntry({
    required this.productoId,
    required this.precio,
    required this.fecha,
  });

  _PrecioEntry copyWith({String? productoId, double? precio, DateTime? fecha}) {
    return _PrecioEntry(
      productoId: productoId ?? this.productoId,
      precio: precio ?? this.precio,
      fecha: fecha ?? this.fecha,
    );
  }
}