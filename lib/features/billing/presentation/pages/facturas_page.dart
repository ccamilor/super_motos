import 'package:flutter/material.dart';

import 'package:super_motos/core/enums/tipo_pago.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/domain/entities/factura.dart';
import 'package:super_motos/features/billing/presentation/pages/factura_detail_page.dart';
import 'package:super_motos/features/billing/presentation/pages/factura_form_page.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/domain/entities/cliente.dart';

class FacturasPage extends StatefulWidget {
  const FacturasPage({super.key});

  @override
  State<FacturasPage> createState() => _FacturasPageState();
}

class _FacturasPageState extends State<FacturasPage> {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final ClientesRepository _clientesRepo = createClientesRepository();

  final TextEditingController _searchController = TextEditingController();

  List<Factura> _facturas = [];
  Map<int, Cliente> _clientesById = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFacturas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacturas() async {
    setState(() => _isLoading = true);
    try {
      final facturas = await _facturasRepo.loadAll();
      final clientes = await _clientesRepo.loadAll();
      if (!mounted) return;
      setState(() {
        _facturas = facturas;
        _clientesById = {for (final c in clientes) c.id: c};
      });
    } catch (e) {
      debugPrint('Error al cargar facturas: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openForm() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const FacturaFormPage()),
    );
    if (saved == true) {
      await _loadFacturas();
    }
  }

  Future<void> _openDetail(Factura factura) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FacturaDetailPage(factura: factura),
      ),
    );
    if (changed == true) {
      await _loadFacturas();
    }
  }

  ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;

  List<Factura> get _filteredFacturas {
    if (_searchQuery.isEmpty) return _facturas;
    final q = _searchQuery.toLowerCase();
    return _facturas.where((f) {
      final matchNumero = f.numeroFactura.toString().contains(q);
      final cliente = _clientesById[f.clienteId];
      final matchCliente = cliente != null && cliente.nombre.toLowerCase().contains(q);
      return matchNumero || matchCliente;
    }).toList();
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

  String _formatFecha(DateTime f) {
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredFacturas;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Historial de Ventas', style: TextStyle(fontWeight: FontWeight.w900)),
            if (_facturas.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_facturas.length}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por numero o cliente...',
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : filtered.isEmpty
                      ? _emptyState(colorScheme)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildFacturaCard(filtered[index], colorScheme);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFacturaCard(Factura factura, ColorScheme colorScheme) {
    final cliente = _clientesById[factura.clienteId];

    return InkWell(
      onTap: () => _openDetail(factura),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Factura #${factura.numeroFactura}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tipoPagoColor(factura.tipoPago, colorScheme).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _tipoPagoColor(factura.tipoPago, colorScheme).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _tipoPagoLabel(factura.tipoPago),
                    style: TextStyle(
                      color: _tipoPagoColor(factura.tipoPago, colorScheme),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cliente?.nombre ?? 'Cliente #${factura.clienteId}',
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _formatFecha(factura.fecha),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${factura.detalles.length} ${factura.detalles.length == 1 ? "item" : "items"}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  formatCOP(factura.total),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            _facturas.isEmpty ? 'No hay ventas registradas' : 'Sin resultados para "$_searchQuery"',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_facturas.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Toca "Nueva Venta" para crear la primera',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
