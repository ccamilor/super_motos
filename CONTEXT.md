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
| Fase 4 — Operación en ruta | 🟡 Parcial | Sync bidireccional ✅, Notificaciones stock bajo ⏳, Geoposicionamiento ⏳ |

---

## 3. Stack técnico

### Plugins principales
- `isar` + `isar_flutter_libs` — base de datos local (Android)
- `supabase_flutter` — backend remoto
- `flutter_local_notifications` — notificaciones locales (pendiente implementar)
- `shared_preferences` — cola de sync offline
- `file_picker` — importación CSV
- `path_provider` — rutas de archivo
- `geolocator` — geoposicionamiento (pendiente)

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
│   │   └── stock_alert_service.dart  # (pendiente implementar)
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
- Acceso rápido (tarjetas Mayra/Mateo): usa los mismos emails que AuthSession
- Login por email/password → Supabase → AuthSession.setUsuario()
- Nombres de usuario hardcoded: "admin@super_motos.com" y "vendedor@super_motos.com"

### Roles (lib/core/enums/rol_usuario.dart)
```dart
enum RolUsuario { admin, vendedor }
```

---

## 6. Credenciales y configuración

### Supabase
- URL y anon key hardcoded en `lib/core/services/supabase_service.dart`
- Tablas en Supabase: clientes, facturas, detalles_factura, devoluciones, proveedores, historial_precios, productos, inventario_camion, inventario_bodega
- Conflict resolution: `onConflict: 'id'` (o `numero_factura` para facturas)

### Usuarios de login
| Nombre | Email | Password | Rol |
|---|---|---|---|
| Mayra | admin@super_motos.com | super_motos2024 | admin |
| Mateo | vendedor@super_motos.com | super_motos2024 | vendedor |

### Dashboard
- `SyncIndicator(pendingCount: SyncService.instance.queueLength)` en cabecera
- Tarjeta "Pendientes de Sinc." con contador dinámico
- Borde cambia a cian cuando hay pendientes

---

## 7. Pending: Notificaciones de stock bajo

### Estado: Pendiente (no implementado)

### Plan
1. Agregar `flutter_local_notifications` en pubspec.yaml
2. Crear `lib/core/services/stock_alert_service.dart`
3. En `InventoryRepository.decrementCamionStock()`, después de decrementar verificar si nueva cantidad < stockMinimo
4. Si bajo umbral → mostrar notificación local
5. Agregar tarjeta "Alertas de Stock" en dashboard con count de productos bajo stock

### Archivos a tocar
- `pubspec.yaml` — + flutter_local_notifications
- `lib/core/services/stock_alert_service.dart` — NUEVO
- `lib/features/inventory/data/repositories/inventory_repository_io.dart` — integrar servicio
- `lib/main.dart` — inicializar plugin
- `lib/features/home/presentation/pages/dashboard_page.dart` — tarjeta de alertas

### Código existente a reutilizar
- `inventory_page.dart:_buildCamionTab()` — ya muestra "STOCK BAJO (Min: N)" como alerta visual
- `ProductoModel.stockMinimo` — umbral por producto
- `decrementCamionStock()` en `inventory_repository_io.dart:71` — lugar donde detectar

---

## 8. Pending: Geoposicionamiento

### Estado: Pendiente (no implementado)

### Plan
1. Agregar `geolocator` + `permission_handler`
2. En `FacturaFormPage` obtener ubicación antes de guardar
3. Campos `latitudVenta` / `longitudVenta` ya existen en `FacturaModel` (nullable)
4. Mostrar ícono de ubicación en `FacturaDetailPage` header

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
|---|---|
| IsarError: Collection id is invalid | `flutter clean` + `build_runner` + reinstalar |
| Impeller crash en emulador x86 | `flutter run --no-enable-impeller` |
| package:web rompe compilación Android | Import condicional con `web_storage_stub.dart` |
| Isar no soporta web | Usar localStorage en Chrome via `package:web` |

---

## 12. Estado de git (al día de hoy)

Commits principales (sesión actual):
- `9be2257` — toJson en todos los modelos + wire sync HistorialPreciosRepository + quick fixes
- `7a15525` — isSynced en todos los modelos + UI sync badges + conflict detection
- `d8840c6` — docs: update agent.md

Rama: `codex-local-first`

---

## 13. Para retomar

```bash
# 1. Obtener última versión
git pull origin codex-local-first

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