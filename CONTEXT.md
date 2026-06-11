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
| Fase 3 — Módulos reales | ✅ | Inventory, Clientes, Facturación, Devoluciones, Auth, Proveedores |
| Fase 4 — Operación en ruta | ✅ | Sync bidireccional, Notificaciones stock bajo, Geoposicionamiento |

---

## 3. Stack técnico

### Plugins principales
- `isar` + `isar_flutter_libs` — base de datos local (Android)
- `supabase_flutter` — backend remoto
- `flutter_local_notifications` — notificaciones locales de stock bajo
- `shared_preferences` — cola de sync offline
- `file_picker` — importación CSV
- `path_provider` — rutas de archivo
- `geolocator` — geoposicionamiento en facturas

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
│   │   ├── stock_alert_service.dart  # Notificaciones de stock bajo
│   │   ├── location_service.dart     # Geolocalización GPS
│   ├── widgets/
│   │   └── sync_status_badge.dart   # SyncStatusBadge + SyncIndicator
│   └── utils/
│       └── currency_formatter.dart  # formatCOP()
└── features/
    ├── auth/              # Usuario entity + model
    ├── billing/           # Facturas (create/list/detail)
    ├── customers/         # Clientes (CRUD)
    ├── home/              # Dashboard
    ├── inventory/         # Producto + InventarioCamion + InventarioBodega
    ├── returns/           # Devoluciones
    └── suppliers/         # Proveedores + HistorialPrecios
```

### Repositorios (patrón)
```dart
// Contrato abstracto
abstract class XRepository {
  Future<List<X>> loadAll();
  Future<X> create(X entity);
  Future<void> delete(int id);
}

// Implementaciones
IsarXRepository    → Android (Isar)
WebXRepository     → Chrome (localStorage + JSON)

// Selección por import condicional
createXRepository() // factory selecciona según plataforma
```

### Modelos Isar (9 colecciones)
1. ProductoModel
2. InventarioCamionModel
3. InventarioBodegaModel
4. ClienteModel
5. FacturaModel
6. UsuarioModel
7. ProveedorModel
8. HistorialPreciosModel
9. DevolucionModel

**Todos tienen `isSynced = false` por defecto y `updatedAt` en `toJson()` para conflict detection.**

---

## 4. Sync (Implementado)

### SyncService (lib/core/services/sync_service.dart)
- Singleton: `SyncService.instance`
- Cola en SharedPreferences (`super_motos_sync_queue`)
- Push automático cada 10 segundos (`Timer.periodic`)
- Pull manual con `pullAll()`
- Conflict detection: compara `updated_at` entre local y server
- Estrategia: `lastWriteWins`
- `getUnsyncedCount(table)`, `getUnsyncedItems(table)`, `isRecordPending(table, id)`
- Tablas soportadas: clientes, facturas, devoluciones, proveedores, historial_precios, productos, inventario_camion, inventario_bodega

### Repositorios con sync conectado
- IsarClientesRepository: create + update + delete
- IsarFacturasRepository: create + delete
- IsarDevolucionesRepository: create + delete
- IsarProveedoresRepository: create + update + delete
- IsarHistorialPreciosRepository: create + delete + deleteByProveedorId
- InventoryRepository: importCsv (sin sync específico — solo local)

### Widgets de sync
- `SyncStatusBadge` — chip compacto (icono nube) o badge completo con label + timestamp
- `SyncIndicator` — header del dashboard ("Todo sincronizado" o "N pendientes")
- Mostrado en: facturas_page, devoluciones_page, clientes_page, proveedores_page, inventory_page (3 tabs), factura_detail_page, devolucion_detail_page

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
- Conflict resolution: `onConflict: 'id'` (o `numero_factura` para facturas)

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
| features/customers/clientes_test.dart | ✅ |
| features/returns/devoluciones_test.dart | ✅ |
| features/suppliers/proveedores_test.dart | ✅ |

**Total: 35 tests pasando**

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

# 5. Implementar siguiente feature (Notificaciones de stock bajo)
#   - Agregar flutter_local_notifications en pubspec.yaml
#   - Crear stock_alert_service.dart
#   - Integrar en inventory_repository_io.dart
#   - Agregar tarjeta en dashboard_page.dart
```

---

## 14. Referencias

- `agent.md` — documentación canónica del proyecto (arquitectura, estado, decisiones)
- `docs/historical.md` — registro histórico del desarrollo
- `flutter-dart-tools` skill — reglas de comandos y workflow