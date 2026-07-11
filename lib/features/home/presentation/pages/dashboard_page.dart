import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:super_motos/core/enums/rol_usuario.dart';
import 'package:super_motos/core/services/auth_session.dart';
import 'package:super_motos/core/services/backup_service.dart';
import 'package:super_motos/core/services/location_service.dart';
import 'package:super_motos/core/services/stock_alert_service.dart';
import 'package:super_motos/core/services/sync_service.dart';
import 'package:super_motos/core/utils/currency_formatter.dart';
import 'package:super_motos/features/auth/presentation/pages/login_page.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository.dart';
import 'package:super_motos/features/billing/data/repositories/facturas_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/billing/data/repositories/facturas_repository_io.dart';
import 'package:super_motos/features/billing/presentation/pages/factura_form_page.dart';
import 'package:super_motos/features/billing/presentation/pages/facturas_page.dart';
import 'package:super_motos/features/customers/presentation/pages/clientes_page.dart';
import 'package:super_motos/features/inventory/presentation/pages/inventory_page.dart';
import 'package:super_motos/features/returns/presentation/pages/devolucion_form_page.dart';
import 'package:super_motos/features/returns/presentation/pages/devoluciones_page.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository.dart';
import 'package:super_motos/features/returns/data/repositories/devoluciones_repository_web.dart'
    if (dart.library.io) 'package:super_motos/features/returns/data/repositories/devoluciones_repository_io.dart';
import 'package:super_motos/features/suppliers/presentation/pages/proveedores_page.dart';
import 'package:super_motos/features/sync/presentation/pages/sync_queue_page.dart';
import 'package:super_motos/features/home/presentation/pages/backup_history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final FacturasRepository _facturasRepo = createFacturasRepository();
  final DevolucionesRepository _devolucionesRepo = createDevolucionesRepository();
  int _lowStockCount = 0;
  double _ventaTotalDia = 0.0;
  double _montoDevolucionesDia = 0.0;
  int _cantidadDevolucionesDia = 0;
  int _facturasHoy = 0;
  double? _latitud;
  double? _longitud;
  String? _ciudad;
  bool _syncButtonLoading = false;
  DateTime? _lastBackupTime;
  String? _lastSyncMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SyncService.instance.syncResultNotifier.addListener(_onSyncResult);
    _updatePendingCount();
    _updateLowStockCount();
    _loadMetrics();
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

  Future<void> _loadMetrics() async {
    try {
      final hoy = DateTime.now();
      final facturas = await _facturasRepo.loadAll();
      final devoluciones = await _devolucionesRepo.loadAll();

      final facturasHoy = facturas.where((f) =>
          f.fecha.year == hoy.year &&
          f.fecha.month == hoy.month &&
          f.fecha.day == hoy.day).toList();

      final devsHoy = devoluciones.where((d) =>
          d.fechaDevolucion.year == hoy.year &&
          d.fechaDevolucion.month == hoy.month &&
          d.fechaDevolucion.day == hoy.day).toList();

      double montoDevs = 0.0;
      for (final d in devsHoy) {
        final factura = facturas.where((f) => f.codigo == d.facturaId).firstOrNull;
        if (factura != null) {
          final detalle = factura.detalles
              .where((det) => det.productoId == d.productoId)
              .firstOrNull;
          if (detalle != null) {
            montoDevs += detalle.precioUnitario * d.cantidad;
          }
        }
      }

      final ventaBruta = facturasHoy.fold(0.0, (sum, f) => sum + f.total);

      if (mounted) {
        setState(() {
          _facturasHoy = facturasHoy.length;
          _cantidadDevolucionesDia = devsHoy.length;
          _montoDevolucionesDia = montoDevs;
          _ventaTotalDia = ventaBruta - montoDevs;
        });
      }
    } catch (e) {
      debugPrint('Error cargando métricas: $e');
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
      _loadMetrics();
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

  String _formatDate(DateTime date) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = AuthSession.instance.currentUser;
    final firstName = user?.nombre.split(' ').first ?? '';
    final pendingSync = SyncService.instance.queueLength;
    final hasLocation = _latitud != null && _longitud != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.two_wheeler, color: colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            const Text(
              'MotoRuta Pro',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          _SyncChip(
            loading: _syncButtonLoading,
            onTap: _triggerSync,
          ),
          const SizedBox(width: 4),
          const _UserAvatar(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(firstName, colorScheme),
              const SizedBox(height: 20),
              _buildMapCard(colorScheme, hasLocation),
              const SizedBox(height: 28),
              _buildMetricsRow(colorScheme),
              const SizedBox(height: 32),
              _buildActionChips(colorScheme),
              const SizedBox(height: 32),
              _buildQuickAccessTitle(theme),
              const SizedBox(height: 14),
              _buildQuickAccessChips(colorScheme),
              if (_lowStockCount > 0 || pendingSync > 0) ...[
                const SizedBox(height: 32),
                _buildAlertsSection(colorScheme),
              ],
              if (_lastBackupTime != null) ...[
                const SizedBox(height: 24),
                _buildBackupInfo(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(String firstName, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}${firstName.isNotEmpty ? ', $firstName' : ''}',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: 0.2,
            height: 1.1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(DateTime.now()),
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(ColorScheme colorScheme, bool hasLocation) {
    if (!hasLocation) {
      return GestureDetector(
        onTap: _loadLocation,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Toca para obtener ubicación',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _loadLocation,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_latitud!, _longitud!),
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.super_motos',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_latitud!, _longitud!),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: colorScheme.error,
                        size: 32,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: colorScheme.secondary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _ciudad ?? '${_latitud!.toStringAsFixed(4)}°, ${_longitud!.toStringAsFixed(4)}°',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(ColorScheme colorScheme) {
    final hasDevoluciones = _cantidadDevolucionesDia > 0;
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _MetricCard(
            label: 'Venta Neta',
            value: formatCOP(_ventaTotalDia),
            icon: Icons.payments_outlined,
            color: colorScheme.primary,
            bgColor: colorScheme.primary.withValues(alpha: 0.08),
            borderColor: colorScheme.primary.withValues(alpha: 0.25),
            width: 190,
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: 'Devoluciones',
            value: '$_cantidadDevolucionesDia',
            subValue: formatCOP(_montoDevolucionesDia),
            icon: Icons.assignment_return_outlined,
            color: hasDevoluciones ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.5),
            bgColor: hasDevoluciones
                ? colorScheme.error.withValues(alpha: 0.08)
                : colorScheme.onSurface.withValues(alpha: 0.04),
            borderColor: hasDevoluciones
                ? colorScheme.error.withValues(alpha: 0.25)
                : colorScheme.onSurface.withValues(alpha: 0.1),
            width: 190,
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: 'Facturas',
            value: '$_facturasHoy',
            icon: Icons.receipt_long_outlined,
            color: colorScheme.secondary,
            bgColor: colorScheme.secondary.withValues(alpha: 0.08),
            borderColor: colorScheme.secondary.withValues(alpha: 0.25),
            width: 170,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildActionChips(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Nueva Venta',
            icon: Icons.shopping_cart_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FacturaFormPage()),
            ),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Devolución',
            icon: Icons.replay_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DevolucionFormPage()),
            ),
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessTitle(ThemeData theme) {
    return Text(
      'Accesos rápidos',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildQuickAccessChips(ColorScheme colorScheme) {
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
        label: 'Inventario',
        icon: Icons.inventory_2_outlined,
        color: colorScheme.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const InventoryPage()),
        ),
      ),
      _QuickAccessItem(
        label: 'Clientes',
        icon: Icons.people_outline_rounded,
        color: colorScheme.secondary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ClientesPage()),
        ),
      ),
      _QuickAccessItem(
        label: 'Facturas',
        icon: Icons.receipt_long_outlined,
        color: Colors.purple,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const FacturasPage()),
        ),
      ),
      _QuickAccessItem(
        label: 'Proveedores',
        icon: Icons.local_shipping_outlined,
        color: Colors.amber,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProveedoresPage()),
        ),
      ),
      _QuickAccessItem(
        label: 'Devoluciones',
        icon: Icons.assignment_return_outlined,
        color: Colors.teal,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DevolucionesPage()),
        ),
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return _QuickAccessChip(item: item);
      }).toList(),
    );
  }

  Widget _buildAlertsSection(ColorScheme colorScheme) {
    final pendingSync = SyncService.instance.queueLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 10),
        if (_lowStockCount > 0)
          _AlertRow(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber,
            title: 'Stock bajo',
            subtitle: '$_lowStockCount producto${_lowStockCount > 1 ? 's' : ''} bajo mínimo',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const InventoryPage(lowStockOnly: true)),
            ),
          ),
        if (_lowStockCount > 0 && pendingSync > 0) const SizedBox(height: 8),
        if (pendingSync > 0)
          _AlertRow(
            icon: Icons.cloud_upload_rounded,
            iconColor: colorScheme.secondary,
            title: 'Pendientes de sync',
            subtitle: '$pendingSync registro${pendingSync > 1 ? 's' : ''} por sincronizar',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SyncQueuePage()),
            ),
          ),
      ],
    );
  }

  Widget _buildBackupInfo(ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BackupHistoryPage()),
        ),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                'Último backup ${_formatBackupTime(_lastBackupTime!)}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncChip extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SyncChip({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(Icons.sync_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Sync',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            _SyncStatusDot(),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pending = SyncService.instance.queueLength;
    final colorScheme = Theme.of(context).colorScheme;
    final color = pending > 0
        ? colorScheme.secondary
        : colorScheme.primary;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAdmin = user.rol == RolUsuario.admin;
    final color = isAdmin ? colorScheme.primary : colorScheme.secondary;
    final initial = user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?';

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.nombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'backup',
          child: Row(
            children: [
              Icon(Icons.cloud_outlined, color: colorScheme.onSurface, size: 18),
              const SizedBox(width: 10),
              const Text('Historial de backups', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: colorScheme.error, size: 18),
              const SizedBox(width: 10),
              Text('Cerrar sesión', style: TextStyle(color: colorScheme.error, fontSize: 13)),
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
        } else if (value == 'backup') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BackupHistoryPage()),
          );
        }
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final double width;

  const _MetricCard({
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subValue!,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return Material(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colorScheme.onPrimary, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickAccessChip extends StatelessWidget {
  final _QuickAccessItem item;

  const _QuickAccessChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 20, color: item.color),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: item.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AlertRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
