import 'package:flutter/material.dart';
import 'package:super_motos/core/utils/code_generator.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

class ProductoFormPage extends StatefulWidget {
  const ProductoFormPage({super.key, this.entry});

  final InventoryEntry? entry;

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final InventoryRepository _repository = createInventoryRepository();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _motosCtrl;
  late final TextEditingController _stockMinCtrl;
  late final TextEditingController _camionCantCtrl;
  late final TextEditingController _canastaCtrl;
  late final TextEditingController _bodegaCantCtrl;

  bool _isOriginal = true;
  bool _agregarCamion = false;
  bool _agregarBodega = false;
  bool _isSaving = false;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _precioCtrl = TextEditingController(text: e?.precio.toStringAsFixed(0) ?? '');
    _motosCtrl = TextEditingController(text: e?.motosCompatibles ?? '');
    _stockMinCtrl = TextEditingController(text: e?.stockMinimo.toString() ?? '0');
    _camionCantCtrl = TextEditingController(text: e?.cantidadCamion.toString() ?? '0');
    _canastaCtrl = TextEditingController(text: e?.canastaId ?? '');
    _bodegaCantCtrl = TextEditingController(text: e?.cantidadBodega.toString() ?? '0');
    _isOriginal = e?.isOriginal ?? true;
    _agregarCamion = (e?.cantidadCamion ?? 0) > 0;
    _agregarBodega = (e?.cantidadBodega ?? 0) > 0;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _motosCtrl.dispose();
    _stockMinCtrl.dispose();
    _camionCantCtrl.dispose();
    _canastaCtrl.dispose();
    _bodegaCantCtrl.dispose();
    super.dispose();
  }

  bool get _canastaVisible =>
      _agregarCamion && int.tryParse(_camionCantCtrl.text) != null && int.parse(_camionCantCtrl.text) > 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final entry = InventoryEntry(
      codigo: widget.entry?.codigo ?? await CodeGenerator.next('PROD'),
      nombre: _nombreCtrl.text.trim(),
      precio: double.tryParse(_precioCtrl.text) ?? 0,
      isOriginal: _isOriginal,
      motosCompatibles: _motosCtrl.text.trim(),
      stockMinimo: int.tryParse(_stockMinCtrl.text) ?? 0,
      cantidadCamion: _agregarCamion ? int.tryParse(_camionCantCtrl.text) ?? 0 : 0,
      canastaId: _canastaVisible ? _canastaCtrl.text.trim() : '',
      cantidadBodega: _agregarBodega ? int.tryParse(_bodegaCantCtrl.text) ?? 0 : 0,
    );

    try {
      if (_isEdit) {
        await _repository.updateProduct(entry);
      } else {
        await _repository.createProduct(entry);
      }
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('DATOS DEL PRODUCTO'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                hintText: 'Ej: Kit de Arrastre Racing Oro',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (COP)',
                hintText: 'Ej: 45000',
              ),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'Ingrese un precio válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Original:', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Sí'),
                  selected: _isOriginal,
                  onSelected: (_) => setState(() => _isOriginal = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('No'),
                  selected: !_isOriginal,
                  onSelected: (_) => setState(() => _isOriginal = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _motosCtrl,
              decoration: const InputDecoration(
                labelText: 'Motos compatibles',
                hintText: 'Ej: Yamaha FZ25, Honda CB190R',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockMinCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock mínimo',
                hintText: 'Ej: 5',
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('STOCK EN CAMIÓN'),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Agregar al camión'),
              value: _agregarCamion,
              onChanged: (v) => setState(() => _agregarCamion = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (_agregarCamion) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _camionCantCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad en camión',
                  hintText: 'Ej: 12',
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_canastaVisible) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _canastaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Canasta ID',
                    hintText: 'Ej: A-2',
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            _sectionHeader('STOCK EN BODEGA'),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Agregar a bodega'),
              value: _agregarBodega,
              onChanged: (v) => setState(() => _agregarBodega = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (_agregarBodega) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodegaCantCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad en bodega',
                  hintText: 'Ej: 35',
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEdit ? 'Guardar cambios' : 'Crear producto',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
