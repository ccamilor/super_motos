# MotoRuta Pro — Contexto completo del proyecto

> Este archivo documenta todo lo necesario para retomar el proyecto desde cualquier punto.
> Creado: 2026-06-04 | Última actualización:ver git log

---

## 1. Resumen del proyecto

**App:** MotoRuta Pro
**Dominio:** Repuestos de moto — inventario de camión del vendedor + bodega central + ventas en ruta
**Stack:** Flutter 3.44 · Dart 3.12 · Isar 3.1 · Supabase (postgresql)
**Plataformas soportadas:**
- **Android / nativo:** Isar como base local
- **Chrome / web:** `localStorage` mediante `package:web` (Isar v3 no soporta web)
**Estrategia:** *local-first*, sync bidireccional con Supabase

---

## 2. Estado actual (Fases completadas)

| Fase | Estado | Descripción |
|---|---|---|
| Fase 1 — Local-first inventario | ✅ | Parser CSV, seed demo, soporte web con localStorage |
| Fase 2 — Backend remoto (Supabase) | ✅ | SupabaseService singleton, SyncService cola offline, conflict detection |
| Fase 3 — Módulos reales | ✅ | Inventory, Clientes, Facturación, Devoluciones, Auth, Proveedores, **Recepción** |
| Fase 4 — Operación en ruta | ✅ | Sync bidireccional, Notificaciones stock bajo, Geoposicionamiento |
| Fase 5 — Flujo CSV→Supabase mejorado | ✅ | Indicador global sync, cola pendientes, export CSV, SyncLog web, backup Supabase Storage |
| **Fase 6 — Release v1.0** | ✅ | Sync fixes, CSV import fix, dashboard reorder, 3-digit codes, Supabase RLS seguridad |

---

## 3. Stack técnico

### Plugins principales
- `isar` + `isar_flutter_libs` — base de datos local (Android)
- `supabase_flutter` — backend remoto
- `flutter_local_notifications` — notificaciones locales de stock bajo
- `shared_preferences` — cola de sync offline + logs web + backup timestamp
- `file_picker` — importación y exportación CSV
- `path_provider` — rutas de archivo
- `geolocator` — geoposicionamiento en facturas
- `sqflite` — sync logs en Android
- `csv` — parser y encoder CSV

### Estructura de datos
```
lib/
├── core/
│   ├── database/         # Isar service (9 schemas)
│   ├── theme/            # JapaniRacerTheme (dark theme)
│   ├── enums/            # EstadoCuenta, RolUsuario, TipoPago
│   ├── services/
│   │   ├── auth_session.dart      # Singleton session
│   │   ├── supabase_service.dart  # Cliente Supabase
│   │   ├── sync_service.dart      # Cola offline + push/pull + conflict detection
│   │   ├── sync_log_service.dart  # Logs de sync (export condicional io/web)
│   │   ├── sync_log_entry.dart    # SyncLogEntry + SyncLogStatus comunes
│   │   ├── backup_service.dart    # Backup automático Supabase Storage
│   │   ├── stock_alert_service.dart  # Notificaciones de stock bajo
│   │   ├── location_service.dart     # Geolocalización GPS
│   ├── widgets/
│   │   └── sync_status_badge.dart   # SyncStatusBadge + SyncIndicator + SyncStateIndicator
│   └── utils/
│       └── currency_formatter.dart  # formatCOP()
└── features/
    ├── auth/              # Usuario entity + model
    ├── billing/           # Facturas (create/list/detail)
    ├── customers/         # Clientes (CRUD)
    ├── home/              # Dashboard
    ├── inventory/         # Producto + InventarioCamion + InventarioBodega
    ├── returns/           # Devoluciones
    ├── suppliers/         # Proveedores + HistorialPrecios
    └── recepcion/         # Recepcion + DetalleRecepcion
```

### Repositorios (patrón)
```dart
// Contrato abstracto
abstract class XRepository {
  Future<List<X>> loadAll();
  Future<X> create(X entity);
  Future<void> delete(String codigo);
}

// Implementaciones
IsarXRepository    → Android (Isar)
WebXRepository     → Chrome (localStorage + JSON)

// Selección por import condicional
createXRepository() // factory selecciona según plataforma
```

### Modelos Isar (11 colecciones)
1. ProductoModel
2. InventarioCamionModel
3. InventarioBodegaModel
4. ClienteModel
5. FacturaModel
6. UsuarioModel
7. ProveedorModel
8. HistorialPreciosModel
9. DevolucionModel
10. RecepcionModel
11. DetalleRecepcionModel

**Todos tienen `isSynced = false` por defecto y `updatedAt` en `toJson()` para conflict detection.**
**Todos tienen `Id id` (PK interno Isar) + `@Index(unique: true) String codigo` como business key.**

---

## 4. Sync (Implementado)

### SyncService (lib/core/services/sync_service.dart)
- Singleton: `SyncService.instance`
- Cola en SharedPreferences (`super_motos_sync_queue`)
- Push automático cada 10 segundos (`Timer.periodic`) — ya no hay push inmediato en `enqueue()`
- Pull manual con `pullAll()` y `forcePushAll()`
- Conflict detection: compara `updated_at` entre local y server
- Estrategia: `lastWriteWins`
- `getUnsyncedCount(table)`, `getUnsyncedItems(table)`, `isRecordPending(table, id)`
- `_markLocalAsSynced()` — tras push exitoso, actualiza `isSynced = true` en Isar local
- `_migrateUnsyncedProducts()` — migración única al iniciar que encolea productos no sincronizados
- Tablas soportadas: clientes, facturas, devoluciones, proveedores, historial_precios, productos, inventario_camion, inventario_bodega, **recepciones, detalles_recepcion**

### Repositorios con sync conectado
- IsarClientesRepository: create + update + delete
- IsarFacturasRepository: create + delete
- IsarDevolucionesRepository: create + delete
- IsarProveedoresRepository: create + update + delete
- IsarHistorialPreciosRepository: create + delete + deleteByProveedorId
- **IsarRecepcionRepository: create + delete**
- InventoryRepository: importCsv (sin sync específico — solo local)

### Widgets de sync
- `SyncStatusBadge` — chip compacto (icono nube) o badge completo con label + timestamp
- `SyncIndicator` — header del dashboard ("Todo sincronizado" o "N pendientes")
- `SyncStateIndicator` — indicador en AppBar con estado en tiempo real, **clicable** → navega a `SyncQueuePage`
- `SyncBadge` — badge superpuesto con contador de pendientes
- `SyncQueuePage` — pantalla "Pendientes de Sync" con items agrupados por tabla, reintentar, eliminar, limpiar
- Tarjeta "Pendientes de Sync" en Dashboard cuando hay items en cola
- Mostrado en: facturas_page, devoluciones_page, clientes_page, proveedores_page, inventory_page (3 tabs), factura_detail_page, devolucion_detail_page, **recepciones_page, recepcion_detail_page**

### BackupService (lib/core/services/backup_service.dart)
- Singleton: `BackupService.instance`
- Exporta inventario a CSV y sube a Supabase Storage bucket `backups/inventory/`
- Auto-backup al iniciar si pasaron >24h desde el último
- Botón manual en AppBar del Dashboard (`cloud_upload_outlined`)
- Último backup persistido en SharedPreferences con tooltip "hace Xh/d"

---

## 5. Auth

### AuthSession (lib/core/services/auth_session.dart)
Singleton que guarda el usuario logueado actual.
- `_hardcodedUsers`: admin@super_motos.com (Mayra, admin) y vendedor@super_motos.com (Mateo, vendedor)
- `currentUser` → Usuario actual
- `isLoggedIn` → bool
- `clear()` → logout

### LoginPage (lib/features/auth/presentation/pages/login_page.dart)
- Acceso rápido (tarjetas Mayra/Mateo): usa directamente `AuthSession.hardcodedUsers` sin pasar por Supabase
- Login por email/password → Supabase → AuthSession.setUsuario()
- Usuarios: `mayra@supermotos.com` y `mateo@supermotos.com`
- Login offline funcional sin conexión a Supabase

### Roles (lib/core/enums/rol_usuario.dart)
```dart
enum RolUsuario { admin, vendedor }
```

---

## 6. Credenciales y configuración

### Supabase
- URL y anon key hardcoded en `lib/core/services/supabase_service.dart`
- Script SQL completo en `database/schema.sql` — ejecutar en SQL Editor de Supabase
- Tablas en Supabase: clientes, facturas, detalles_factura, devoluciones, proveedores, historial_precios, productos, inventario_camion, inventario_bodega
- Todas las tablas usan `TEXT` primary keys (campo `id` en Supabase = `codigo` del modelo)
- Conflict resolution: `onConflict: 'codigo'` (o `numero_factura` para facturas)

### Usuarios de login
| Nombre | Email | Password | Rol |
|---|---|---|---|
| Mayra | mayra@supermotos.com | super_motos2024 | admin |
| Mateo | mateo@supermotos.com | super_motos2024 | vendedor |

### Dashboard
- `SyncIndicator(pendingCount: SyncService.instance.queueLength)` en cabecera
- Tarjeta "Pendientes de Sinc." con contador dinámico
- Borde cambia a cian cuando hay pendientes

---

## 7. Notificaciones de stock bajo

### Estado: Implementado

- `StockAlertService` singleton en `lib/core/services/stock_alert_service.dart`
- Verificación en `inventory_repository_io.dart:decrementCamionStock()` — si nueva cantidad < stockMinimo, dispara notificación local
- Tarjeta ámbar en dashboard con conteo persistente via SharedPreferences

---

## 8. Geoposicionamiento

### Estado: Implementado

- `LocationService` singleton en `lib/core/services/location_service.dart`
- Captura de coordenadas al guardar factura en `FacturaFormPage`
- Muestra icono + coordenadas en `FacturaDetailPage` footer
- Permisos: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` en `AndroidManifest.xml`, `NSLocationWhenInUseUsageDescription` en `Info.plist`

---

## 9. Comandos de trabajo

```bash
# Dependencias
flutter pub get

# Regenerar schemas Isar (OBLIGATORIO tras modificar *_model.dart)
dart run build_runner build --delete-conflicting-outputs

# Análisis
flutter analyze

# Tests
flutter test  # toda la suite

# Ejecutar
flutter run -d chrome --web-port 8080
flutter run -d emulator-5554 --no-enable-impeller  # workaround Impeller en x86

# Limpiar
flutter clean && flutter pub get
```

---

## 10. Tests

| Test | Estado |
|---|---|
| csv_import_test.dart (10 tests) | ✅ |
| widget_test.dart | ✅ |
| features/inventory/inventory_test.dart | ✅ |
| features/auth/auth_session_test.dart | ✅ |
| features/billing/facturas_test.dart | ✅ |
| features/customers/clientes/clientes_test.dart | ✅ |
| features/returns/devoluciones_test.dart | ✅ |
| features/suppliers/proveedores_test.dart | ✅ |
| **features/recepcion/recepcion_test.dart (12 tests)** | ✅ |

**Total: 47 tests pasando**

---

## 11. Problemas conocidos

| Problema | Workaround |
|---|---|---|
| IsarError: Collection id is invalid | `flutter clean` + `build_runner` + reinstalar |
| Impeller crash en emulador x86 | `flutter run --no-enable-impeller` |
| package:web rompe compilación Android | Import condicional con `web_storage_stub.dart` |
| Isar no soporta web | Usar localStorage en Chrome via `package:web` |
| Supabase Auth schema no inicializado en proyecto nuevo | Crear proyecto nuevo y esperar ~2 min a que esté activo antes de ejecutar SQL. Usar Dashboard (no SQL) para crear usuarios auth |

---

## 12. Estado de git (al día de hoy)

Commits principales (sesión actual):
- `c268302` — feat: add database/schema.sql + fix Supabase URL for login
- `47d76e4` — docs: update agent + historical with Supabase project recreation session
- `3d3072d` — fix(sync_status_badge): missing closing parens in Border.all calls
- `ffb8f19` — fix(login): quick login bypasses Supabase using hardcoded users
- `bf4f1df` — fix(tests): silence SyncService push errors in test environment
- `cbabcd5` — feat(geolocation): add LocationService + capture coords on factura save
- `08457f3` — feat(notifications): add stock alert service + dashboard card

Rama principal: `conociendo_agentes_back`
Rama U/I: `U/I_details`

---

## 13. Para retomar

```bash
# 1. Obtener última versión
git pull origin conociendo_agentes_back

# 2. Instalar deps
flutter pub get

# 3. Regenerar Isar (por si hay cambios pendientes)
dart run build_runner build --delete-conflicting-outputs

# 4. Correr análisis y tests
flutter analyze
flutter test

# 5. Próximos features sugeridos
#   - Export CSV ya implementado (botón en AppBar de Inventario)
#   - Backup automático a Supabase Storage ya implementado
#   - Sync Log compatible web (Chrome ya soportado)
#   - Dashboard con métricas dinámicas completas
```

---

## 14. Referencias

- `agent.md` — documentación canónica del proyecto (arquitectura, estado, decisiones)
- `docs/historical.md` — registro histórico del desarrollo
- `docs/testing_guide.md` — guía completa de pruebas para todos los módulos
- `flutter-dart-tools` skill — reglas de comandos y workflow

---

## 15. InventoryPage UI (2026-06-11)

### Estructura de scroll
- `NestedScrollView` con `headerSliverBuilder`
- `SliverAppBar(pinned: false, floating: true, snap: true)` → search colapza
- `SliverPersistentHeader(pinned: true)` → TabBar FIJA arriba
- `_TabBarHeaderDelegate` implementa el TabBar persistente

### Navegación
- Flecha de regreso: `Scaffold AppBar` con `leading: IconButton(arrow_back)` — FIJA
- Search: `prefixIcon: Icon(Icons.search, colorScheme.primary)` — icono verde
- `SliverAppBar`: `automaticallyImplyLeading: false` — sin icono automático
- `FAB`: "Nuevo Producto" visible solo en tab Inventario Total

### Layout de tarjetas (punto medio de legibilidad)
- `ListView.separated` (no GridView) — altura fija ~76-80px
- Cards horizontales: Row 2 columnas (badge+info | price+stats)
- Padding: `EdgeInsets.all(12)`
- Divisor vertical: 70px alto

### Fonts (tamaño punto medio)
| Elemento | Tamaño |
|---|---|
| Título | 15px bold |
| Subtítulo | 12px |
| Precio | 15px bold |
| Valores numéricos | 14px bold |
| Labels | 11px |
| Badge/Alert | 10px |

### Badge y alertas (Total tab)
- "ORIGINAL" / "GENÉRICO" — texto completo
- "STOCK BAJO" en rojo (`colorScheme.error`) — sin icono
- Condición: `camion.cantidad < producto.stockMinimo`

### Archivo modificado
- `lib/features/inventory/presentation/pages/inventory_page.dart`

### Commits de esta sesión
- `fix(ui): reduce padding/spacing in cards, fix indentation, grid overflow issues`
- `fix(scaffold): add FAB and fix icon conflicts in AppBar and SliverAppBar`

---

## 16. Migración a String ID (2026-06-19)

### Cambio principal
Todos los identificadores de dominio migraron de `int id` a `String codigo` (alfanumérico libre).

### Modelos Isar
- `Id id` — auto-increment, PK interno de Isar (no expuesto al dominio)
- `@Index(unique: true) String codigo` — business key visible en todo el dominio

### Entidades de dominio
- Todas usan `String codigo` como identificador principal
- `delete(String codigo)` en todos los repositorios (antes `delete(int id)`)

### Supabase
- Todas las tablas usan `TEXT` primary keys
- El campo `id` en Supabase contiene el valor de `codigo` del modelo
- Conflict resolution: `onConflict: 'codigo'`

### CSV
- Primera columna: `codigo` (String) — antes `id` (int)
- Columna canasta: `canasta_id` (String) — antes `numero_canasta` (int)

### Seed data — prefijos por entidad
| Prefijo | Entidad | Ejemplo |
|---|---|---|
| `PROD-` | Producto | `PROD-001` |
| `CLI-` | Cliente | `CLI-001` |
| `FAC-` | Factura | `FAC-001` |
| `DEV-` | Devolución | `DEV-001` |
| `PROV-` | Proveedor | `PROV-001` |
| `HP-` | HistorialPrecio | `HP-001` |
| `USR-` | Usuario | `USR-001` |

### Canastas
- Alfanuméricas: `A-1`, `B-2`, `C-3`, etc.
- Antes eran numéricas: `1`, `2`, `3`, etc.

---

## 17. Mejoras flujo CSV→Supabase (2026-06-21)

### 1. Visibilidad de Sync en UI ✅
- `SyncStateIndicator` en AppBar de **6 páginas** (inventory, clientes, facturas, proveedores, devoluciones, recepciones)
- **Clicable** → navega a `SyncQueuePage`
- Dashboard: tarjeta "Pendientes de Sync" con contador dinámico
- Toast/Snackbar al completar push/pull

### 2. Validación y Preview del CSV ✅
- `CsvPreviewModal` muestra primeras 5 filas, detecta columnas requeridas
- Detección y conteo de duplicados (nuevos vs existentes)
- Reporte post-import: "X creados, Y actualizados, Z total"

### 3. Manejo de errores robusto ✅
- Retry automático con backoff exponencial (máx 5 intentos, 5 min)
- `SyncQueuePage` con items agrupados por tabla + Reintentar/Eliminar/Limpiar
- Log local persistente (Android: sqflite, Chrome: SharedPreferences)

### 4. UX para CSVs grandes ✅
- Progress bar con `LinearProgressIndicator` + nombre del ítem actual
- Chunking de 500 filas para no bloquear UI
- `CancelToken` para cancelación

### 5. Export / Backup ✅
- **Exportar CSV**: botón en AppBar de Inventario, guarda en archivo (Android) o descarga (Chrome)
- **Backup automático**: `BackupService` sube CSV a Supabase Storage bucket `backups/inventory/` cada 24h
- **Backup manual**: botón `cloud_upload_outlined` en Dashboard con tooltip "hace Xh/d"

### SyncLogService cross-platform ✅
- `sync_log_entry.dart` — SyncLogEntry + SyncLogStatus comunes
- `sync_log_service_io.dart` — Android (sqflite)
- `sync_log_service_web.dart` — Chrome (SharedPreferences)
- Factory `createSyncLogService()` con import condicional

### Archivos creados (10)
| Archivo | Propósito |
|---|---|
| `inventory_csv_exporter.dart` | Serializa InventoryEntry → CSV |
| `inventory_file_writer_io.dart` | Guardar archivo Android |
| `inventory_file_writer_web.dart` | Descargar Chrome |
| `inventory_file_writer_stub.dart` | Stub condicional |
| `sync_log_entry.dart` | SyncLogEntry + SyncLogStatus |
| `sync_log_service_stub.dart` | Interfaz + factory |
| `sync_log_service_io.dart` | Impl Android (sqflite) |
| `sync_log_service_web.dart` | Impl Chrome (SharedPreferences) |
| `backup_service.dart` | Backup a Supabase Storage |

### Bugs corregidos
- `inventory_page.dart`: ambiguous import `createInventoryRepository`, `StreamController` sin import, `lastProgress` no definido
- `withOpacity` deprecado reemplazado por `withValues` en 3 archivos

---

## 18. CodeGenerator — Códigos de 3 dígitos (2026-06-22)

### Archivo
`lib/core/utils/code_generator.dart`

### Funcionamiento
- Contador secuencial por prefijo, persistido en `SharedPreferences`
- En primera ejecución, escanea Isar para encontrar el máximo número existente y evita colisiones
- Si el contador almacenado es ≥ 1000 (legado de códigos largos con timestamp), fuerza re-escaneo
- Fallback a timestamp original si SharedPreferences no está disponible (tests)

### Prefijos
| Prefijo | Entidad | Primer código |
|---------|---------|--------------|
| `CLI-` | Cliente | `CLI-001` |
| `FAC-` | Factura | `FAC-001` |
| `DEV-` | Devolución | `DEV-001` |
| `PROV-` | Proveedor | `PROV-001` |
| `PVHS-` | HistorialPrecio | `PVHS-001` |
| `REC-` | Recepción | `REC-001` |
| `PROD-` | Producto | `PROD-001` (seed data) → `PROD-007` (nuevos) |

### Uso
```dart
codigo: await CodeGenerator.next('CLI'),   // → CLI-001, CLI-002...
codigo: await CodeGenerator.next('FAC'),   // → FAC-001, FAC-002...
```

---

## 19. Dashboard Reorder + Sync Snackbar Fix (2026-06-22)

### Nuevo orden del Dashboard
```
1. Ubicación            (GPS)
2. Operaciones de Ruta  (Nueva Venta + Devolución)
3. (Alertas Stock / Backup / Pendientes Sync)
4. Accesos Rápidos      (Inventario, Clientes, Facturas, Proveedores, Devoluciones)
5. Métricas del Día     (Venta Neta, Clientes, Productos, Devoluciones Hoy)
```

### Fix Sync Snackbars repetitivos
Se agregaron 2 guards en `dashboard_page.dart:_onSyncResult()`:
- `pushed == 0 && failed == 0` → no muestra snackbar cuando solo se encola algo sin sync real
- `message == _lastSyncMessage` → no repite el mismo mensaje (evita spam del timer cada 10s)

### Devoluciones en Accesos Rápidos
- Nuevo item en grid con icono `replay_outlined` y color teal
- Navega a `DevolucionesPage`
- Renombrado "Historial" → "Facturas"

---

## 20. RLS Supabase — Producción (2026-06-22)

### Cambio en `database/schema.sql`
| Rol | Antes | Ahora |
|-----|-------|-------|
| `anon` | `FOR ALL` (lectura + escritura) | `FOR SELECT` (solo lectura) |
| `authenticated` | `FOR ALL` (sin cambios) | `FOR ALL` (sin cambios) |

### Storage backups
- Política `"Public access for backups"` → reemplazada por `"Authenticated access for backups"`
- Solo usuarios autenticados pueden listar/borrar backups

### SQL para aplicar en producción
```sql
-- Ejecutar en Supabase SQL Editor
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon, authenticated;
```
(Los GRANT ya están ejecutados. Las políticas RLS controlan el acceso a nivel fila.)