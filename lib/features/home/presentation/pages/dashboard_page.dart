import 'package:flutter/material.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/core/services/location_service.dart';
import 'package:super_motos/core/services/stock_alert_service.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/core/widgets/sync_status_badge.dart';
import 'package:super_motos/features/auth/presentation/pages/login_page.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/presentation/pages/factura_form_page.dart';
import 'package:super_motos/features/billing/presentation/pages/facturas_page.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository.dart';
import 'package:super_motos/features/customers/data/repositories/clientes_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/customers/data/repositories/clientes_repository_io.dart';
import 'package:super_motos/features/customers/presentation/pages/clientes_page.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository.dart';
import 'package:super_motos/features/inventory/data/repositories/inventory_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/inventory/data/repositories/inventory_repository_io.dart';
import 'package:super_motos/features/inventory/presentation/pages/inventory_page.dart';
import 'package:super_motos/features/returns/presentation/pages/devolucion_form_page.dart';
import 'package:super_motos/features/suppliers/presentation/pages/proveedores_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final ClientesRepository _clientesRepo = createClientesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();
  int _pendingCount = 0;
  int _lowStockCount = 0;
  double _ventaTotalDia = 0.0;
  int _totalClientes = 0;
  int _totalProductos = 0;
  double? _latitud;
  double? _longitud;
  String? _ciudad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updatePendingCount();
    _updateLowStockCount();
    _loadVentaTotal();
    _loadTotalClientes();
    _loadTotalProductos();
    _loadLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePendingCount();
      _updateLowStockCount();
      _loadVentaTotal();
      _loadTotalClientes();
      _loadTotalProductos();
      _loadLocation();
    }
  }

  void _updatePendingCount() {
    if (mounted) {
      setState(() {
        _pendingCount = SyncService.instance.queueLength;
      });
    }
  }

  Future<void> _updateLowStockCount() async {
    final count = await StockAlertService.instance.getLowStockAlertCount();
    if (mounted) {
      setState(() {
        _lowStockCount = count;
      });
    }
  }

  Future<void> _loadVentaTotal() async {
    try {
      final facturas = await _facturasRepo.loadAll();
      final hoy = DateTime.now();
      final total = facturas
          .where((f) =>
              f.fecha.year == hoy.year &&
              f.fecha.month == hoy.month &&
              f.fecha.day == hoy.day)
          .fold(0.0, (sum, f) => sum + f.total);
      if (mounted) {
        setState(() {
          _ventaTotalDia = total;
        });
      }
    } catch (e) {
      debugPrint('Error calculando venta total: $e');
    }
  }

  Future<void> _loadTotalClientes() async {
    try {
      final clientes = await _clientesRepo.loadAll();
      if (mounted) setState(() => _totalClientes = clientes.length);
    } catch (e) {
      debugPrint('Error cargando total clientes: $e');
    }
  }

  Future<void> _loadTotalProductos() async {
    try {
      final snapshot = await _inventoryRepo.loadInventory();
      if (mounted) setState(() => _totalProductos = snapshot.productos.length);
    } catch (e) {
      debugPrint('Error cargando total productos: $e');
    }
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      if (mounted && pos != null) {
        final cityName = await LocationService.instance.getCityName();
        if (mounted) {
          setState(() {
            _latitud = pos.latitude;
            _longitud = pos.longitude;
            _ciudad = cityName;
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.two_wheeler, color: colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'MotoRuta Pro',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          _UserBadge(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SyncIndicator(pendingCount: _pendingCount),
              const SizedBox(height: 16),
              Text(
                'Métricas del Día',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      colorScheme: colorScheme,
                      label: 'Venta Total',
                      value: formatCOP(_ventaTotalDia),
                      valueColor: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      colorScheme: colorScheme,
                      label: 'Total Clientes',
                      value: '$_totalClientes',
                      valueColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      colorScheme: colorScheme,
                      label: 'Total Productos',
                      value: '$_totalProductos',
                      valueColor: colorScheme.secondary,
                      borderColor: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLocationCard(colorScheme),
                  ),
                ],
              ),
              if (_lowStockCount > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InventoryPage()),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alertas de Stock',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_lowStockCount producto${_lowStockCount > 1 ? 's' : ''} bajo stock minimo',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Main Grid: 2x2 tarjetas (Inventario, Clientes, Historial, Proveedores)
              Text(
                'Accesos Rapidos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [
                  _buildShortcutCard(
                    context,
                    title: 'Inventario',
                    icon: Icons.inventory_2_outlined,
                    bgColor: colorScheme.primary.withValues(alpha: 0.1),
                    iconColor: colorScheme.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const InventoryPage()),
                    ),
                  ),

                  _buildShortcutCard(
                    context,
                    title: 'Clientes',
                    icon: Icons.people_outline_rounded,
                    bgColor: colorScheme.secondary.withValues(alpha: 0.1),
                    iconColor: colorScheme.secondary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ClientesPage()),
                    ),
                  ),
                  _buildShortcutCard(
                    context,
                    title: 'Historial',
                    icon: Icons.history_edu_outlined,
                    bgColor: colorScheme.error.withValues(alpha: 0.1),
                    iconColor: colorScheme.error,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FacturasPage()),
                    ),
                  ),
                  _buildShortcutCard(
                    context,
                    title: 'Proveedores',
                    icon: Icons.local_shipping_outlined,
                    bgColor: Colors.purple.withValues(alpha: 0.1),
                    iconColor: Colors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProveedoresPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Floating/Highlighted Buttons: Nueva Venta y Devolucion
              Card(
                elevation: 4,
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Operaciones de Ruta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const FacturaFormPage()),
                              ),
                              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                              label: const Text('Nueva Venta'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const DevolucionFormPage()),
                              ),
                              icon: const Icon(Icons.replay_outlined, size: 20),
                              label: const Text('Devolucion'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required Color valueColor,
    Color? borderColor,
  }) {
    final border = borderColor ?? colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: border.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ColorScheme colorScheme) {
    final hasLocation = _latitud != null && _longitud != null;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasLocation
              ? colorScheme.secondary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: hasLocation ? colorScheme.secondary : Colors.white38,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ubicación',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasLocation ? Colors.white70 : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasLocation)
              Text(
                _ciudad ?? '${_latitud!.toStringAsFixed(3)}° / ${_longitud!.toStringAsFixed(3)}°',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.secondary,
                ),
              )
            else ...[
              Text(
                'Sin datos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _loadLocation,
                child: Text(
                  'Obtener ubicación',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthSession.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdmin = user.rol == RolUsuario.admin;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: (isAdmin ? colorScheme.primary : colorScheme.secondary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                .withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAdmin ? colorScheme.primary : colorScheme.secondary,
                boxShadow: [
                  BoxShadow(
                    color: (isAdmin ? colorScheme.primary : colorScheme.secondary)
                        .withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              user.nombre,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAdmin ? colorScheme.primary : colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isAdmin ? colorScheme.primary : colorScheme.secondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cerrar sesion',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          AuthSession.instance.clear();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
    );
  }
}
