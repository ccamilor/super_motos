# Super Motos — Guía del Agente

> Documento canónico para que `opencode` (o cualquier asistente) entienda el proyecto en una sola lectura.
> Si algo cambia, se actualiza **aquí primero**; `README.md` queda como índice rápido y `docs/historical.md` conserva el registro de cambios pasados.

---

## 1. Resumen del proyecto

- **App:** MotoRuta Pro
- **Dominio:** Repuestos de moto — inventario de camión del vendedor + bodega central + ventas en ruta
- **Stack:** Flutter 3.44 · Dart 3.12 · Isar 3.1
- **Plataformas soportadas:**
  - **Android / nativo:** Isar como base local
  - **Chrome / web:** `localStorage` mediante `package:web` (Isar v3 no soporta web)
- **Estrategia actual:** *local-first*, sin backend remoto conectado

---

## 2. Estado actual

| Feature | Estado | Notas |
|---|---|---|
| `inventory` | ✅ Completo | Carga, búsqueda, importación CSV, formato COP, 3 pestañas |
| `customers` | ✅ Completo | CRUD: lista con búsqueda, crear/editar/eliminar, formato COP, soporte Isar + web |
| `billing` | ✅ Completo | Listado + crear con line items + detalle; descuenta stock del camión al guardar |
| `returns` | ✅ Completo | Listado + crear con factura/producto filtrado + detalle; repone stock del camión al guardar |
| `home` (dashboard) | ✅ UI | Todas las tarjetas y botones de Operaciones de Ruta navegan a módulos reales |
| `auth` | ✅ Completo | Login con 2 usuarios (Mayra admin, Mateo vendedor), session singleton, logout |
| `suppliers` | ✅ Completo | CRUD: lista con busqueda, crear/editar/eliminar, historial de precios colapsable dentro del form |
| Backend remoto (Supabase) | 🟡 Inicializado | `supabase_flutter` instalado, `SupabaseService` singleton, LoginPage con email/password, credenciales configuradas |
| Sincronización bidireccional | ❌ No implementada | Estrategia: last-write-wins (pending) |

**Leyenda:** ✅ funcional · 🟡 parcial / sólo esqueleto · ❌ no iniciado

---

## 3. Arquitectura

```text
UI (Flutter)
  └── InventoryRepository (contrato abstracto)
        ├── IsarInventoryRepository   → Android / nativo
        └── WebInventoryRepository    → Chrome (localStorage)
              │
              ├── InventoryCsvParser   (parser común)
              └── InventorySeedData    (semilla demo unificada)
```

**Patrón clave:** *import condicional* por plataforma

```dart
// IO (Android):
import 'web_storage_stub.dart'
    if (dart.library.io) 'web_storage_web.dart';

// JS interop (Chrome):
import 'web_storage_stub.dart'
    if (dart.library.js_interop) 'web_storage_web.dart';
```

Esto evita que tipos `JSAny`/`JSObject` de `package:web` rompan la compilación nativa de Android.

---

## 4. Estructura de carpetas

```text
super_motos/
├── lib/
│   ├── main.dart                              # Entry point — inicializa Isar y lanza app
│   ├── core/
│   │   ├── database/isar_service.dart         # Apertura de Isar con 9 schemas
│   │   ├── theme/app_theme.dart               # Tema dark "JapaniRacer"
│   │   ├── enums/                             # estado_cuenta, rol_usuario
│   │   └── services/sync_service.dart         # (placeholder de sync futura)
│   └── features/
│       ├── auth/                              # model + entity
│       ├── billing/                           # model + entity
│       ├── customers/                         # model + entity
│       ├── home/                              # dashboard
│       ├── inventory/                         # ⭐ módulo principal
│       │   ├── data/
│       │   │   ├── models/                    # producto, inventario_camion, inventario_bodega
│       │   │   ├── repositories/              # contrato + impl web + impl io + snapshot
│       │   │   └── services/                  # csv parser + seed data
│       │   ├── domain/entities/              # inventory_entry, producto, etc.
│       │   └── presentation/pages/            # inventory_page + web_storage_stub/web
│       ├── returns/                           # model + entity
│       └── suppliers/                         # model + entity
├── test/
│   ├── csv_import_test.dart                   # 10/10 tests del flujo CSV
│   ├── widget_test.dart                       # smoke test
│   └── features/inventory/inventory_test.dart # tests por feature
├── test_data/
│   └── inventario_prueba.csv                  # 12 productos demo en COP
├── docs/
│   └── historical.md                          # registro histórico del refactor
├── pubspec.yaml
└── agent.md                                   # ← este archivo
```

---

## 5. Features (detalle por módulo)

### 5.1 `inventory` — único módulo funcional hoy

**Tres pestañas en `InventoryPage`:**

| Pestaña | Contenido | Alerta visual |
|---|---|---|
| Mi Camión | Producto + cantidad + número de canasta | `STOCK BAJO` si `cantidad < stockMinimo` |
| Bodega Central | Producto + stock bodega | Indicador "ALMACÉN CENTRAL" |
| Inventario Total | Camión + Bodega consolidados | `REABASTECIMIENTO SUGERIDO` si camión bajo y bodega con stock |

**Capacidades:**
- Búsqueda por `nombre` o `motos_compatibles`
- Botón **"Cargar CSV"** → `FilePicker` → parse → persist → reload
- Precios formateados en COP (`$ 35.000 COP`)

### 5.2 `home` (dashboard)

- AppBar con título `MotoRuta Pro` y badge "Online" decorativo
- 2 métricas en duro: `Venta Total $0.00` y `Pendientes de Sinc. 0`
- Grid 3×1: Inventario, Clientes, Historial (los 3 funcionales)
- Card "Operaciones de Ruta": Nueva Venta (abre `FacturaFormPage`), Devolución (abre `DevolucionFormPage`)

### 5.3 `customers` — módulo completo

**Pantallas:**
- `ClientesPage`: lista con búsqueda (por `nombre` o `identificadorFiscal`), card por cliente con badge de estado, NIT, dirección, saldo y límite en COP. FAB "+ Nuevo" y tap en card abren el form. Icono papelera con confirmación.
- `ClienteFormPage`: 3 secciones (Datos básicos, Crédito, Estado). Validadores en cada campo. Saldo pendiente en modo edición es read-only (lo modifica facturación). Confirmación al descartar con cambios.

**Capa de datos:** mismo patrón que inventario.
```text
ClientesRepository (contrato abstracto)
  ├── IsarClientesRepository   → Android / nativo
  └── WebClientesRepository    → Chrome (localStorage con JSON)
```
Factory con import condicional: `createClientesRepository()`.

**Entidad `Cliente`:** 9 campos + `copyWith` (usado por el form para construir el update).

**Seed demo (3 clientes):** cubren los 3 estados de `EstadoCuenta` (activo, sinCredito, suspendido). El cliente #2 excede el límite de crédito para ejercitar la alerta visual.

**Test:** `test/features/customers/clientes_test.dart` — 4 tests CRUD sobre el contrato del repositorio Isar.

### 5.4 Stubs (modelos sin UI)

`auth`, `suppliers`: sólo existe el modelo Isar + entidad de dominio. **No tocar** salvo que se vaya a implementar la UI o el flujo.

### 5.5 `billing` — módulo completo

**Pantallas:**
- `FacturasPage`: historial con búsqueda (por `numeroFactura` o `cliente.nombre`), card por factura con fecha, cliente, badge de tipoPago y total COP. FAB "+ Nueva Venta".
- `FacturaFormPage`: 3 secciones (Cliente, Productos, Pago). Cliente via `DropdownButtonFormField`. Productos via modal con lista buscable. Pago via `DropdownButtonFormField<TipoPago>`. Footer sticky con total. **Descuenta stock del camión al guardar**.
- `FacturaDetailPage`: header con cliente + tipoPago + total; lista de líneas; footer con fecha/vendedor/estado sync. Botón eliminar (sin restaurar stock).

**Capa de datos:** mismo patrón que inventory/customers.
```text
FacturasRepository (contrato abstracto)
  ├── IsarFacturasRepository   → Android / nativo
  └── WebFacturasRepository    → Chrome (localStorage con JSON)
```

**Cross-module:** al guardar una factura se invoca `InventoryRepository.decrementCamionStock(productoId, cantidad)` por cada línea. Si el stock decrement falla, se registra warning pero la factura queda guardada con `isSynced=false` para reproceso manual.

**Enums nuevos:** `TipoPago { contado, credito, transferencia }` (mapeado a `String` en Isar para no regenerar el `.g.dart`).

**Tests:** `test/features/billing/facturas_test.dart` — 7 tests cubriendo CRUD + stock decrement (happy path, insufficient, missing record).

### 5.6 `returns` — módulo completo

**Pantallas:**
- `DevolucionesPage`: historial con búsqueda (por `facturaId`, `motivo` o `numeroCanastaDestino`), card por devolución con factura, producto, motivo, fecha, canasta destino y badge "+N" de cantidad. FAB "+ Nueva Devolucion".
- `DevolucionFormPage`: secciones progresivas (Factura → Producto → Detalle → Motivo). Producto se filtra automáticamente por la factura seleccionada, mostrando "(facturado: N)" en cada opción. Cantidad se valida contra el máximo facturado. Motivo es DropdownButton con 4 opciones comunes + "Otro" que revela TextField multiline. Footer muestra preview "+N al stock del camion". **Repone stock del camión al guardar**.
- `DevolucionDetailPage`: header con id + "STOCK REPUESTO +N"; rows de detalles (factura, producto, cantidad, canasta, motivo); footer con fecha + estado sync. Botón eliminar (sin descontar stock).

**Capa de datos:** mismo patrón.
```text
DevolucionesRepository (contrato abstracto)
  ├── IsarDevolucionesRepository   → Android / nativo
  └── WebDevolucionesRepository    → Chrome (localStorage con JSON)
```

**Cross-module:** al guardar una devolución se invoca `InventoryRepository.incrementCamionStock(productoId, cantidad)`. Inverso del decrement de facturación.

**Tipo de IDs:** `facturaId` y `productoId` son `String` (no se regeneró el `.g.dart` existente). Se serializa con `.toString()` al guardar y `int.tryParse` al leer.

**Tests:** `test/features/returns/devoluciones_test.dart` — 6 tests cubriendo CRUD + incrementCamionStock.

### 5.7 `suppliers` — módulo completo

**Pantallas:**
- `ProveedoresPage`: lista con búsqueda (por `nombre` o `nit`), card por proveedor con nit, dirección y teléfono. FAB "+ Nuevo" y tap en card abren el form. Icono papelera con confirmación.
- `ProveedorFormPage`: 2 secciones (Datos del proveedor, Historial de precios). Datos: nombre, nit, teléfono, dirección. Historial: sección colapsable que permite agregar múltiples registros de precio (producto dropdown del inventario + precio). Solo se guarda historial al guardar el proveedor (no es independiente).

**Capa de datos:** mismo patrón que inventory/customers/billing.
```text
ProveedoresRepository (contrato abstracto)
  ├── IsarProveedoresRepository   → Android / nativo
  └── WebProveedoresRepository    → Chrome (localStorage con JSON)

HistorialPreciosRepository (contrato abstracto)
  ├── IsarHistorialPreciosRepository   → Android / nativo
  └── WebHistorialPreciosRepository    → Chrome (localStorage con JSON)
```
Factory con import condicional: `createProveedoresRepository()` y `createHistorialPreciosRepository()`.

**Entidades:** `Proveedor` (4 campos + copyWith), `HistorialPrecio` (4 campos + copyWith).

**Cross-module:** el form de proveedor usa `InventoryRepository.loadInventory().productos` para el dropdown de productos. No modifica stock.

**Seed demo (3 proveedores):** Repuestos Moto JC (Bogotá), Distribuidora Pegasus (Medellín), Importados El Sol (Cali). Además 3 registros de historial de precios demo (precio compra por producto/proveedor).

**Tests:** `test/features/suppliers/proveedores_test.dart` — 4 tests cubriendo CRUD.

---

## 6. Modelo de datos

### 6.1 Colecciones Isar (9)

Registradas en `lib/core/database/isar_service.dart`:

| Colección | Archivo | Propósito |
|---|---|---|
| `ProductoModel` | `features/inventory/data/models/producto_model.dart` | Catálogo de repuestos |
| `InventarioCamionModel` | `features/inventory/data/models/inventario_camion_model.dart` | Stock en el camión del vendedor |
| `InventarioBodegaModel` | `features/inventory/data/models/inventario_bodega_model.dart` | Stock en bodega central |
| `ClienteModel` | `features/customers/data/models/cliente_model.dart` | Clientes |
| `FacturaModel` | `features/billing/data/models/factura_model.dart` | Facturas de venta |
| `UsuarioModel` | `features/auth/data/models/usuario_model.dart` | Usuarios del sistema |
| `ProveedorModel` | `features/suppliers/data/models/proveedor_model.dart` | Proveedores |
| `HistorialPreciosModel` | `features/suppliers/data/models/historial_precios_model.dart` | Historial de precios |
| `DevolucionModel` | `features/returns/data/models/devolucion_model.dart` | Devoluciones |

### 6.2 Entidades de dominio

- `InventoryEntry` (DTO común): una fila del inventario, sin acoplar a Isar.
- `InventorySnapshot`: transporta las 3 listas (`productos`, `camion`, `bodega`) entre capas.
- Entidades paralelas a modelos: `Producto`, `InventarioCamion`, `InventarioBodega`, `Cliente`, `Factura`, `Usuario`, `Proveedor`, `Devolucion`.

**Regla:** la UI no toca modelos Isar directamente; consume el repositorio, que devuelve `InventorySnapshot`.

---

## 7. Flujo de inventario

```text
1. InventoryPage.initState()           → _loadInventory()
2. _repository.loadInventory()
       ├── Web: lee localStorage["super_motos_csv_data"]
       │        ├── si hay → InventoryCsvParser.parse()
       │        └── si no  → InventorySeedData.demoEntries
       └── IO: lee de Isar
3. snapshot.productos / camion / bodega → setState → render
4. Usuario toca "Cargar CSV"
       ├── FilePicker.pickFiles(extensions: ['csv'], withData: kIsWeb)
       ├── Lee bytes (web) o path (io)
       ├── _repository.importCsv(content)
       │        ├── parser
       │        ├── persist (localStorage en web / Isar txn en nativo)
       │        └── devuelve snapshot
       └── setState + SnackBar "EXITO"
```

**Detección de encabezado:** `InventoryEntry.isHeaderRow()` chequea si la primera celda es `id` o la segunda es `nombre`; en tal caso, la salta.

**Mapeo de fila CSV → modelos:** `InventoryEntry.fromCsvRow()` produce la entidad; `.toProductoModel()`, `.toCamionModel()`, `.toBodegaModel()` la proyectan a Isar.

---

## 8. Reglas de plataforma

| Regla | Detalle |
|---|---|
| `kIsWeb` gating | Isar **no** se inicializa en web (línea 18 de `isar_service.dart`) |
| `package:web` solo en Chrome | Tipos `JSAny`/`JSObject` no existen en runtime nativo → patrón stub |
| `FilePicker.withData` | `true` en web (carga bytes), `false` en móvil (usa path) |
| `dart:io` vs `dart:js_interop` | Selección de archivo de import condicional |
| Almacenamiento web | Clave única: `super_motos_csv_data` (CSV completo en `localStorage`) |

---

## 9. Convenciones de código

- **No añadir comentarios** al código (regla explícita del proyecto).
- **Nombres:** `snake_case` para archivos, `PascalCase` para clases, `lowerCamelCase` para variables.
- **Formato COP** (función `_formatCOP`):
  - Entrada `35000.0` → Salida `$ 35.000 COP`
  - Entrada `185000.0` → Salida `$ 185.000 COP`
  - Implementado con regex `(\d{1,3})(?=(\d{3})+(?!\d))` + `replaceAllMapped`.
- **Repositorios:** contrato abstracto en `data/repositories/inventory_repository.dart`, dos implementaciones (`_web.dart` y `_io.dart`) seleccionadas por import condicional.
- **Feature-first:** cada feature autocontenida con `data/`, `domain/`, `presentation/`.
- **Tests:** viven en `test/` (raíz) o `test/features/<feature>/` (por feature).

---

## 10. Comandos esenciales

```bash
# Dependencias
flutter pub get

# Regenerar schemas Isar (OBLIGATORIO al modificar modelos *_model.dart)
dart run build_runner build --delete-conflicting-outputs

# Análisis estático
flutter analyze

# Tests
flutter test test/csv_import_test.dart
flutter test test/widget_test.dart
flutter test test/features/inventory/inventory_test.dart

# Ejecutar
flutter run -d chrome --web-port 8080
flutter run -d emulator-5554 --no-enable-impeller   # workaround Impeller x86

# Limpiar cache
flutter clean && flutter pub get
```

---

## 11. Tests

| Archivo | Cobertura | Estado |
|---|---|---|
| `test/csv_import_test.dart` | 10 tests: parseo, header, mapeo, seed, formato COP, simulación completa | ✅ 10/10 |
| `test/widget_test.dart` | Smoke test de la app real (reemplazó el obsoleto del counter) | ✅ |
| `test/features/inventory/inventory_test.dart` | Tests por feature (parser/snapshot) | ✅ |

> Detalle exhaustivo de cada test en [`docs/historical.md`](./docs/historical.md).

---

## 12. Problemas conocidos

| Problema | Causa | Solución / workaround |
|---|---|---|
| `IsarError: Collection id is invalid` en emulador | BD del emulador con schemas antiguos incompatibles | `flutter clean` + `build_runner build` + reinstalar app |
| Crash de Impeller en emulador x86 (API 30) | Backend GLES del emulador no enlaza shaders de Impeller | `flutter run --no-enable-impeller` (en físico funciona bien) |
| `package:web` rompe compilación Android | Tipos `JSAny`/`JSObject` no existen en runtime nativo | Patrón de import condicional con `web_storage_stub.dart` |
| `flutter test` y `dart analyze` se cuelgan en sesión | Observado en `documentacion_refactor.md` (ya no aplica) | Re-ejecutar tras unos segundos; alternar con `flutter test --no-pub` |

---

## 13. Hoja de ruta

**Fase 1 — Local-first inventario** ✅ (completada)
- Repositorio abstracto, parser CSV, seed demo, soporte web con `localStorage`.

**Fase 2 — Backend remoto (Supabase)** ⏭️ (siguiente)
- Crear cuenta y proyecto Supabase
- Diseñar schema remoto equivalente al Isar
- Conectar primero inventario, después facturación y devoluciones
- Definir estrategia de sincronización bidireccional
- Definir estrategia de resolución de conflictos (pendiente)

**Fase 3 — Módulos reales**
- ✅ Clientes (UI + CRUD) — completado
- ✅ Facturación (UI + flujo de venta + descuento de stock) — completado
- ✅ Devoluciones (UI + flujo de retorno a canasta + reposición de stock) — completado
- Autenticación (login + roles: `RolUsuario`, `EstadoCuenta` ya existen como enums)

**Fase 4 — Operación en ruta**
- Geoposicionamiento en factura (ya mencionado en el dashboard)
- Notificaciones de stock bajo en tiempo real
- Sincronización en background

---

## 14. Índice de archivos clave

| Ruta | Propósito |
|---|---|
| `lib/main.dart` | Entry point — inicializa Isar y lanza `MyApp` |
| `lib/core/database/isar_service.dart` | Apertura de Isar con 9 schemas |
| `lib/core/theme/app_theme.dart` | Tema dark `JapaniRacerTheme` |
| `lib/core/utils/currency_formatter.dart` | `formatCOP(double)` — formato monetario COP |
| `lib/core/enums/tipo_pago.dart` | `TipoPago { contado, credito, transferencia }` |
| `lib/core/constants/vendedor.dart` | `kVendedorPorDefecto = 1` (placeholder hasta auth) |
| `lib/core/services/sync_service.dart` | Placeholder de sync (fase 2) |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Dashboard principal |
| `lib/features/inventory/presentation/pages/inventory_page.dart` | Pantalla de inventario con 3 tabs |
| `lib/features/customers/presentation/pages/clientes_page.dart` | Lista de clientes con búsqueda |
| `lib/features/customers/presentation/pages/cliente_form_page.dart` | Form crear/editar cliente |
| `lib/features/customers/data/repositories/clientes_repository.dart` | Contrato abstracto |
| `lib/features/customers/data/repositories/clientes_repository_web.dart` | Impl web (localStorage + JSON) |
| `lib/features/customers/data/repositories/clientes_repository_io.dart` | Impl nativa (Isar) |
| `lib/features/customers/data/services/clientes_seed_data.dart` | 3 clientes demo cubriendo los 3 estados |
| `lib/features/billing/presentation/pages/facturas_page.dart` | Historial de ventas con búsqueda |
| `lib/features/billing/presentation/pages/factura_form_page.dart` | Form crear venta con line items + stock decrement |
| `lib/features/billing/presentation/pages/factura_detail_page.dart` | Detalle de factura con delete |
| `lib/features/billing/data/repositories/facturas_repository.dart` | Contrato abstracto |
| `lib/features/billing/data/repositories/facturas_repository_io.dart` | Impl nativa (Isar) |
| `lib/features/billing/data/repositories/facturas_repository_web.dart` | Impl web (localStorage + JSON) |
| `lib/features/billing/data/services/facturas_seed_data.dart` | 2 facturas demo (contado + credito) |
| `lib/features/returns/presentation/pages/devoluciones_page.dart` | Historial de devoluciones con búsqueda |
| `lib/features/returns/presentation/pages/devolucion_form_page.dart` | Form crear devolucion con factura/producto filtrado + restock |
| `lib/features/returns/presentation/pages/devolucion_detail_page.dart` | Detalle de devolucion con delete |
| `lib/features/returns/data/repositories/devoluciones_repository.dart` | Contrato abstracto |
| `lib/features/returns/data/repositories/devoluciones_repository_io.dart` | Impl nativa (Isar) |
| `lib/features/returns/data/repositories/devoluciones_repository_web.dart` | Impl web (localStorage + JSON) |
| `lib/features/returns/data/services/devoluciones_seed_data.dart` | 2 devoluciones demo (defecto + producto incorrecto) |
| `lib/features/inventory/presentation/pages/web_storage_stub.dart` | Stub de localStorage para Android |
| `lib/features/inventory/presentation/pages/web_storage_web.dart` | Impl localStorage para Chrome |
| `lib/features/inventory/data/repositories/inventory_repository.dart` | Contrato abstracto |
| `lib/features/inventory/data/repositories/inventory_repository_web.dart` | Impl web (`localStorage`) |
| `lib/features/inventory/data/repositories/inventory_repository_io.dart` | Impl nativa (Isar) |
| `lib/features/inventory/data/repositories/inventory_snapshot.dart` | DTO de salida del repositorio |
| `lib/features/inventory/data/services/inventory_csv_parser.dart` | Parser CSV común |
| `lib/features/inventory/data/services/inventory_seed_data.dart` | Semilla demo unificada |
| `lib/features/inventory/domain/entities/inventory_entry.dart` | DTO común de fila de inventario |
| `test/csv_import_test.dart` | Suite de 10 tests del flujo CSV |
| `test_data/inventario_prueba.csv` | CSV de prueba con 12 productos COP |
| `pubspec.yaml` | Dependencias: `isar`, `csv`, `file_picker`, `web`, `path_provider`, `supabase_flutter` |
| `lib/core/services/supabase_service.dart` | Cliente singleton Supabase (URL + anon key hardcoded) |
| `docs/historical.md` | Registro histórico del refactor inicial |

---

## Ver también

- [`README.md`](./README.md) — Índice rápido y comandos de uso
- [`docs/historical.md`](./docs/historical.md) — Walkthrough técnico del refactor + registro de sesiones

---

## Nota sobre ejecución en Chrome

> ⚠️ **No soportado actualmente.** Los archivos `.g.dart` generados por Isar contienen IDs int64 que JavaScript no puede representar (±2⁵³). Intentar `flutter run -d chrome` produce errores `The integer literal X can't be represented exactly in JavaScript` en 9 archivos. **Usar Android** (`flutter run -d emulator-5554 --no-enable-impeller` o dispositivo físico) para desarrollo local.
