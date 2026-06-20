import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_motos/core/enums/estado_cuenta.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ClientesRepository _repository = createClientesRepository();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _limiteCtrl;
  late final TextEditingController _saldoCtrl;
  late EstadoCuenta _estado;

  bool _isSaving = false;
  bool _isDirty = false;

  bool get _isEdit => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _nitCtrl = TextEditingController(text: c?.identificadorFiscal ?? '');
    _direccionCtrl = TextEditingController(text: c?.direccion ?? '');
    _limiteCtrl = TextEditingController(text: c?.limiteCredito.toStringAsFixed(0) ?? '0');
    _saldoCtrl = TextEditingController(text: c?.saldoPendiente.toStringAsFixed(0) ?? '0');
    _estado = c?.estadoCuenta ?? EstadoCuenta.activo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _limiteCtrl.dispose();
    _saldoCtrl.dispose();
    super.dispose();
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
      final limite = double.parse(_limiteCtrl.text.trim());
      final saldo = double.parse(_saldoCtrl.text.trim());
      final nuevo = Cliente(
        codigo: widget.cliente?.codigo ?? '',
        nombre: _nombreCtrl.text.trim(),
        identificadorFiscal: _nitCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
        latitud: widget.cliente?.latitud,
        longitud: widget.cliente?.longitud,
        limiteCredito: limite,
        saldoPendiente: saldo,
        estadoCuenta: _estado,
      );

      if (_isEdit) {
        await _repository.update(nuevo);
      } else {
        await _repository.create(nuevo);
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
          title: Text(
            _isEdit ? 'Editar cliente' : 'Nuevo cliente',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () {
                if (!_isDirty) {
                  setState(() => _isDirty = true);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Datos basicos', colorScheme),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Tienda Don Repuesto',
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
                      labelText: 'NIT / Identificador fiscal',
                      hintText: 'Solo digitos',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'El NIT es obligatorio';
                      }
                      if (v.trim().length < 6) {
                        return 'El NIT debe tener al menos 6 digitos';
                      }
                      return null;
                    },
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
                  _sectionLabel('Credito', colorScheme),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _limiteCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Limite de credito (COP)',
                      hintText: '0',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'El limite es obligatorio';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return 'Valor invalido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _saldoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Saldo pendiente (COP)',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      helperText: _isEdit
                          ? 'Se modifica automaticamente desde facturacion'
                          : null,
                      filled: _isEdit,
                      fillColor: _isEdit ? colorScheme.surface : null,
                    ),
                    enabled: !_isEdit,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'El saldo es obligatorio';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return 'Valor invalido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Estado de cuenta', colorScheme),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EstadoCuenta>(
                    initialValue: _estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: Icon(Icons.toggle_on_outlined),
                    ),
                    items: EstadoCuenta.values
                        .map(
                          (e) => DropdownMenuItem<EstadoCuenta>(
                            value: e,
                            child: Text(_estadoLabel(e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _estado = v);
                    },
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

  String _estadoLabel(EstadoCuenta estado) {
    switch (estado) {
      case EstadoCuenta.activo:
        return 'Activo';
      case EstadoCuenta.suspendido:
        return 'Suspendido';
      case EstadoCuenta.sinCredito:
        return 'Sin credito';
    }
  }
}
