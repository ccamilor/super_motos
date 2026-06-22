import 'package:flutter/material.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/core/services/backup_service.dart';
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
import 'package:super_motos/features/returns/presentation/pages/devoluciones_page.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/returns/data/repositories/devoluciones_repository_io.dart';
import 'package:super_motos/features/suppliers/presentation/pages/proveedores_page.dart';
import 'package:super_motos/features/sync/presentation/widgets/sync_badge.dart';
import 'package:super_motos/features/sync/presentation/pages/sync_queue_page.dart';
import 'package:super_motos/features/home/presentation/pages/backup_history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final ClientesRepository _clientesRepo = createClientesRepository();
  final InventoryRepository _inventoryRepo = createInventoryRepository();
  final DevolucionesRepository _devolucionesRepo = createDevolucionesRepository();
  int _lowStockCount = 0;
  double _ventaTotalDia = 0.0;
  double _ventaBrutaDia = 0.0;
  double _montoDevolucionesDia = 0.0;
  int _cantidadDevolucionesDia = 0;
  int _totalClientes = 0;
  int _totalProductos = 0;
  double? _latitud;
  double? _longitud;
  String? _ciudad;
  bool _syncButtonLoading = false;
  bool _backupButtonLoading = false;
  DateTime? _lastBackupTime;
  String? _lastSyncMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SyncService.instance.syncResultNotifier.addListener(_onSyncResult);
    _updatePendingCount();
    _updateLowStockCount();
    _loadVentaTotal();
    _loadDevolucionesDia();
    _loadTotalClientes();
    _loadTotalProductos();
    _loadLocation();
    _loadLastBackupTime();
    _performAutoBackup();
  }

  Future<void> _loadLastBackupTime() async {
    final time = await BackupService.instance.getLastBackupTime();
    if (mounted) {
      setState(() => _lastBackupTime = time);
    }
  }

  Future<void> _performAutoBackup() async {
    final shouldBackup = await BackupService.instance.shouldBackup();
    if (shouldBackup && mounted) {
      final success = await BackupService.instance.performBackup();
      if (success && mounted) {
        _loadLastBackupTime();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup automático completado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _triggerManualBackup() async {
    setState(() => _backupButtonLoading = true);
    
    final success = await BackupService.instance.performBackup();
    
    if (mounted) {
      setState(() => _backupButtonLoading = false);
      
      if (success) {
        _loadLastBackupTime();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup completado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al realizar backup'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SyncService.instance.syncResultNotifier.removeListener(_onSyncResult);
    super.dispose();
  }

  void _onSyncResult() {
    final result = SyncService.instance.syncResultNotifier.value;
    if (result.timestamp.year == 2000) return;
    if (!mounted) return;

    _updatePendingCount();

    if (result.pushed == 0 && result.failed == 0) return;

    String message;
    Color bgColor;
    switch (result.status) {
      case SyncStatus.synced:
        final partes = <String>[];
        if (result.pushed > 0) partes.add('${result.pushed} subidos');
        if (result.failed > 0) partes.add('${result.failed} fallidos');
        final detalle = partes.isNotEmpty ? ' ($partes)' : '';
        message = 'Sincronizacion exitosa$detalle';
        bgColor = Theme.of(context).colorScheme.primary;
      case SyncStatus.error:
        message = 'Fallo en sincronizacion: ${result.failed} registro${result.failed == 1 ? '' : 's'} pendiente${result.failed == 1 ? '' : 's'}';
        bgColor = Theme.of(context).colorScheme.error;
      default:
        return;
    }

    if (message == _lastSyncMessage) return;
    _lastSyncMessage = message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePendingCount();
      _updateLowStockCount();
      _loadVentaTotal();
      _loadDevolucionesDia();
      _loadTotalClientes();
      _loadTotalProductos();
      _loadLocation();
    }
  }

  void _updatePendingCount() {
    if (mounted) {
      setState(() {});
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

  Future<void> _triggerSync() async {
    setState(() => _syncButtonLoading = true);
    await SyncService.instance.forcePushAll();
    await SyncService.instance.pullAll();
    if (mounted) {
      setState(() => _syncButtonLoading = false);
      _updatePendingCount();
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
          _ventaBrutaDia = total;
          _ventaTotalDia = total - _montoDevolucionesDia;
        });
      }
    } catch (e) {
      debugPrint('Error calculando venta total: $e');
    }
  }

  Future<void> _loadDevolucionesDia() async {
    try {
      final devoluciones = await _devolucionesRepo.loadAll();
      final facturas = await _facturasRepo.loadAll();
      final hoy = DateTime.now();

      final devsHoy = devoluciones.where((d) =>
          d.fechaDevolucion.year == hoy.year &&
          d.fechaDevolucion.month == hoy.month &&
          d.fechaDevolucion.day == hoy.day).toList();

      double montoTotal = 0.0;
      for (final d in devsHoy) {
        final factura = facturas.where((f) => f.codigo == d.facturaId).firstOrNull;
        if (factura != null) {
          final detalle = factura.detalles
              .where((det) => det.productoId == d.productoId)
              .firstOrNull;
          if (detalle != null) {
            montoTotal += detalle.precioUnitario * d.cantidad;
          }
        }
      }

      if (mounted) {
        setState(() {
          _cantidadDevolucionesDia = devsHoy.length;
          _montoDevolucionesDia = montoTotal;
          _ventaTotalDia = _ventaBrutaDia - montoTotal;
        });
      }
    } catch (e) {
      debugPrint('Error calculando devoluciones del dia: $e');
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
            Flexible(
              child: Text(
                'MotoRuta Pro',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SyncBadge(
            child: IconButton(
              onPressed: _syncButtonLoading ? null : _triggerSync,
              icon: _syncButtonLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.sync, color: colorScheme.primary),
              tooltip: 'Sincronizar ahora',
            ),
          ),
          IconButton(
            onPressed: _backupButtonLoading ? null : _triggerManualBackup,
            icon: _backupButtonLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.cloud_upload_outlined, color: colorScheme.primary),
            tooltip: 'Backup manual',
          ),
          _UserBadge(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SyncQueuePage()),
                ),
                borderRadius: BorderRadius.circular(8),
                child: const SyncStateIndicator(),
              ),
              const SizedBox(height: 16),

              _buildLocationCard(colorScheme),

              const SizedBox(height: 20),

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

              if (_lastBackupTime != null) ...[
                const SizedBox(height: 12),
                _buildBackupCard(colorScheme),
              ],
              if (_lowStockCount > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InventoryPage(lowStockOnly: true)),
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
              if (SyncService.instance.queueLength > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SyncQueuePage()),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.5),
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
                              color: colorScheme.secondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_upload_rounded,
                              color: colorScheme.secondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pendientes de Sync',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${SyncService.instance.queueLength} registro${SyncService.instance.queueLength > 1 ? 's' : ''} por sincronizar',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

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
                    title: 'Facturas',
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
                  _buildShortcutCard(
                    context,
                    title: 'Devoluciones',
                    icon: Icons.replay_outlined,
                    bgColor: Colors.teal.withValues(alpha: 0.1),
                    iconColor: Colors.teal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const DevolucionesPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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
                      label: 'Venta Neta',
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
                    child: _buildDevolucionesCard(colorScheme),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBackupTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${time.day}/${time.month}/${time.year}';
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

  Widget _buildDevolucionesCard(ColorScheme colorScheme) {
    final hasDevoluciones = _cantidadDevolucionesDia > 0;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDevoluciones
              ? colorScheme.error.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.03),
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
                  Icons.assignment_return_outlined,
                  size: 14,
                  color: hasDevoluciones ? colorScheme.error : Colors.white38,
                ),
                const SizedBox(width: 4),
                Text(
                  'Devoluciones Hoy',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasDevoluciones ? Colors.white70 : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_cantidadDevolucionesDia}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: hasDevoluciones ? colorScheme.error : Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatCOP(_montoDevolucionesDia),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasDevoluciones ? colorScheme.error.withValues(alpha: 0.8) : Colors.white38,
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

  Widget _buildBackupCard(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_done_outlined,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Backup',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ultimo: ${_formatBackupTime(_lastBackupTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupHistoryPage()),
              ),
              icon: const Icon(Icons.history, size: 16),
              label: const Text('Ver historial', style: TextStyle(fontSize: 12)),
            ),
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
