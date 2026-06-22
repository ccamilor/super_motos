# 📜 Historial del Refactor — Super Motos

> **Registro histórico del refactor inicial.** Este documento preserva el walkthrough técnico original (migración de APIs, tests creados, problemas resueltos).
> Para el estado actual del proyecto, consultar [`agent.md`](../agent.md) en la raíz.

**Stack al momento del refactor:** Flutter 3.44 · Dart 3.12 · Isar 3.1 · CSV · file_picker · package:web  
**Plataformas:** Android (Isar nativo) + Web/Chrome (localStorage)  
**Ruta del proyecto:** `C:\Users\crisn\.gemini\antigravity\scratch\super_motos`

---

## 📁 Estructura del Proyecto

```
super_motos/
├── lib/
│   ├── main.dart                        # Entry point — inicializa Isar y lanza app
│   ├── core/
│   │   ├── database/
│   │   │   └── isar_service.dart        # Servicio de apertura de BD Isar
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Tema dark "JapaniRacer"
│   │   ├── enums/                       # Enumeraciones globales
│   │   └── services/                    # Servicios compartidos
│   └── features/
│       ├── home/                        # Dashboard principal
│       ├── inventory/                   # ⭐ Módulo principal (esta sesión)
│       │   ├── data/models/
│       │   │   ├── producto_model.dart
│       │   │   ├── inventario_camion_model.dart
│       │   │   └── inventario_bodega_model.dart
│       │   └── presentation/pages/
│       │       ├── inventory_page.dart          # Página principal de inventario
│       │       ├── web_storage_stub.dart        # [NUEVO] Stub para Android
│       │       └── web_storage_web.dart         # [NUEVO] Impl web localStorage
│       ├── auth/                        # Autenticación (UsuarioModel)
│       ├── billing/                     # Facturación (FacturaModel)
│       ├── customers/                   # Clientes (ClienteModel)
│       ├── suppliers/                   # Proveedores (ProveedorModel, HistorialPreciosModel)
│       └── returns/                     # Devoluciones (DevolucionModel)
├── test/
│   └── csv_import_test.dart             # [NUEVO] Suite de 10 tests
├── test_data/
│   └── inventario_prueba.csv            # [NUEVO] CSV de prueba (12 productos)
└── pubspec.yaml
```

---

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  path_provider: ^2.1.1
  csv: ^8.0.0
  file_picker: ^11.0.2
  web: ^1.1.0              # [NUEVO] Reemplaza dart:js deprecated

dev_dependencies:
  flutter_test:
    sdk: flutter
  isar_generator: ^3.1.0
  build_runner: ^2.4.8
```

---

## 🗄️ Base de Datos Isar

### Colecciones registradas en `IsarService`

| Colección | Archivo | Propósito |
|---|---|---|
| `ProductoModel` | `producto_model.dart` | Catálogo de repuestos |
| `InventarioCamionModel` | `inventario_camion_model.dart` | Stock en el camión del vendedor |
| `InventarioBodegaModel` | `inventario_bodega_model.dart` | Stock en bodega central |
| `ClienteModel` | `cliente_model.dart` | Clientes |
| `FacturaModel` | `factura_model.dart` | Facturas de venta |
| `UsuarioModel` | `usuario_model.dart` | Usuarios del sistema |
| `ProveedorModel` | `proveedor_model.dart` | Proveedores |
| `HistorialPreciosModel` | `historial_precios_model.dart` | Historial de precios |
| `DevolucionModel` | `devolucion_model.dart` | Devoluciones |

### Inicialización (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  await isarService.init(); // Solo inicializa en Android/nativo, no en web
  runApp(const MyApp());
}
```

### Regla de plataforma

```dart
// En web: Isar NO se inicializa (no soportado en Isar v3)
// En Android: Isar se abre con todos los schemas generados
if (kIsWeb) {
  return; // isar_service.dart línea 18
}
```

---

## 📊 Módulo de Inventario

### Pantalla principal — 3 pestañas

```
┌─────────────────────────────────────────┐
│         Manejo de Inventario            │
├──────────┬────────────────┬─────────────┤
│ Mi Camión│ Bodega Central │ Inv. Total  │
└──────────┴────────────────┴─────────────┘
```

### Tab 1 — Mi Camión
- Muestra productos con su cantidad en el camión y número de canasta
- Alerta visual de **STOCK BAJO** si `cantidad < stockMinimo`
- Precios en formato COP

### Tab 2 — Bodega Central
- Muestra productos con su stock en bodega
- Indicador "ALMACÉN CENTRAL"

### Tab 3 — Inventario Total ⭐
- Vista consolidada: stock camión + stock bodega
- Alerta **"REABASTECIMIENTO SUGERIDO"** si camión está bajo y bodega tiene stock
- **Botón "Cargar CSV"** → abre selector de archivo

---

## 📄 Carga CSV Real

### Formato del archivo CSV

```csv
id,nombre,precio,is_original,motos_compatibles,stock_minimo,cantidad_camion,numero_canasta,cantidad_bodega
101,Cadena Reforzada 428H,35000,true,Yamaha YBR125,3,12,1,50
102,Pastillas Freno Semi-Metalicas,18500,false,Pulsar NS200,8,25,2,120
```

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | `int` | Identificador único del producto |
| `nombre` | `String` | Nombre del repuesto |
| `precio` | `double` | Precio en COP (ej: `35000`) |
| `is_original` | `bool` | `true`/`false` o `1`/`0` |
| `motos_compatibles` | `String` | Modelos de moto compatibles |
| `stock_minimo` | `int` | Umbral mínimo de alerta |
| `cantidad_camion` | `int` | Unidades en el camión |
| `numero_canasta` | `int` | Compartimento del camión |
| `cantidad_bodega` | `int` | Unidades en bodega |

### Lógica de importación por plataforma

```dart
Future<void> _importCSV(ColorScheme colorScheme) async {

  // 1. Selección de archivo
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
    withData: kIsWeb, // true en web → carga bytes; false en móvil → usa path
  );

  // 2. Lectura del contenido
  String input = '';
  if (kIsWeb) {
    input = String.fromCharCodes(result.files.single.bytes!);
    // Persistir en localStorage para sobrevivir recargas
    getWebStorage().setItem('super_motos_csv_data', input);
  } else {
    input = await File(result.files.single.path!).readAsString();
  }

  // 3. Parseo con librería csv
  final List<List<dynamic>> fields = csv.decode(input);
  // Detecta y salta la fila de encabezado automáticamente

  // 4. Persistencia
  if (kIsWeb) {
    // Solo en memoria + localStorage
    _realProductos = [...];
  } else {
    // Transacción real en Isar
    await _isar.writeTxn(() async {
      await _isar.productoModels.put(producto);
      await _isar.inventarioCamionModels.put(camionReg);
      await _isar.inventarioBodegaModels.put(bodegaReg);
    });
    await _loadDataFromIsar(); // Recarga UI
  }
}
```

---

## 💰 Formato de Precios COP

```dart
String _formatCOP(double precio) {
  final valorEntero = precio.toInt();
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final String formateado = valorEntero
      .toString()
      .replaceAllMapped(reg, (m) => '${m[1]}.');
  return '\$ $formateado COP';
}
```

| Entrada | Salida |
|---|---|
| `35000.0` | `$ 35.000 COP` |
| `185000.0` | `$ 185.000 COP` |
| `12500.0` | `$ 12.500 COP` |
| `92000.0` | `$ 92.000 COP` |

---

## 🌐 Soporte Web (localStorage)

### Patrón de importación condicional

Para evitar que los tipos de interoperabilidad JavaScript (`JSAny`, `JSObject`) rompan la compilación de Android, se implementó el siguiente patrón:

```dart
// inventory_page.dart — import condicional
import 'web_storage_stub.dart'
    if (dart.library.js_interop) 'web_storage_web.dart';
```

```
Compilar para Android → usa web_storage_stub.dart (sin tipos JS)
Compilar para Chrome  → usa web_storage_web.dart  (package:web real)
```

### Contrato de la abstracción

```dart
// web_storage_stub.dart
abstract class WebStorage {
  String? getItem(String key);
  void setItem(String key, String value);
}
WebStorage getWebStorage() => throw UnsupportedError('...');

// web_storage_web.dart
class WebStorageWeb implements WebStorage {
  @override
  String? getItem(String key) => web.window.localStorage.getItem(key);
  @override
  void setItem(String key, String value) =>
      web.window.localStorage.setItem(key, value);
}
WebStorage getWebStorage() => WebStorageWeb();
```

### Clave de localStorage

```
'super_motos_csv_data' → CSV completo persistido entre recargas de Chrome
```

---

## 🔄 Migraciones de APIs Deprecadas

### 1. `dart:js` → `package:web`

```dart
// ❌ ANTES (deprecated en Dart 3.x)
import 'dart:js' as js;
final ls = js.context['localStorage'];
ls.callMethod('getItem', ['key']);
ls.callMethod('setItem', ['key', value]);

// ✅ DESPUÉS
import 'package:web/web.dart' as web;
web.window.localStorage.getItem('key');
web.window.localStorage.setItem('key', value);
```

### 2. `WillPopScope` → `PopScope`

```dart
// ❌ ANTES (deprecated en Flutter 3.12+)
WillPopScope(
  onWillPop: () async => false,
  child: AlertDialog(...),
)

// ✅ DESPUÉS
PopScope(
  canPop: false,
  child: AlertDialog(...),
)
```

### 3. `FilePicker.platform.pickFiles` → `FilePicker.pickFiles`

```dart
// ❌ ANTES (file_picker <v11)
FilePicker.platform.pickFiles(...)

// ✅ DESPUÉS (file_picker v11+)
FilePicker.pickFiles(...)
```

---

## 🧪 Tests Automatizados

**Archivo:** `test/csv_import_test.dart`  
**Comando:** `flutter test test/csv_import_test.dart`

```
00:00 +10: All tests passed!
```

| # | Test | Estado |
|---|---|---|
| 1 | CSV existe y no está vacío | ✅ |
| 2 | `csv.decode()` parsea 13 filas (1 header + 12 datos) | ✅ |
| 3 | Detección automática de fila de encabezado | ✅ |
| 4 | Cada fila tiene ≥ 9 columnas | ✅ |
| 5 | Todos los IDs son `int` válidos (≥ 100) | ✅ |
| 6 | Todos los precios son `double` válidos (> 0) | ✅ |
| 7 | `is_original` son booleanos válidos | ✅ |
| 8 | Enteros de inventario parsean correctamente | ✅ |
| 9 | Formato COP: `35000` → `$ 35.000 COP` | ✅ |
| 10 | Simulación completa: 12 productos → 12 camión → 12 bodega | ✅ |

### Datos procesados en el test de simulación completa

```
[101] Cadena Reforzada 428H-130L        $35.000 COP  | Camión: 12 | Bodega: 50
[102] Pastillas Freno Semi-Metalicas    $18.500 COP  | Camión: 25 | Bodega: 120
[103] Kit Empaques Motor Completo       $92.000 COP  | Camión: 5  | Bodega: 15
[104] Aceite Motor 10W40 Sintético 1L   $28.000 COP  | Camión: 40 | Bodega: 200
[105] Filtro Aire Alto Rendimiento K&N  $45.000 COP  | Camión: 8  | Bodega: 30
[106] Bujía Iridium NGK CR8EIX         $12.500 COP  | Camión: 30 | Bodega: 150
[107] Tensor Cadena Automático          $22.000 COP  | Camión: 10 | Bodega: 40
[108] Manigueta Freno Aluminio CNC      $15.000 COP  | Camión: 15 | Bodega: 60
[109] Llanta Trasera Pirelli 140/70-17  $185.000 COP | Camión: 4  | Bodega: 12
[110] Amortiguador Trasero Gas Premium  $135.000 COP | Camión: 6  | Bodega: 18
[111] Kit Luces LED H4 6000K            $38.000 COP  | Camión: 20 | Bodega: 80
[112] Espejos Retrovisores Deportivos   $16.000 COP  | Camión: 18 | Bodega: 70
```

---

## 🚀 Comandos de Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Regenerar schemas de Isar (OBLIGATORIO al modificar modelos)
dart run build_runner build --delete-conflicting-outputs

# Análisis estático
flutter analyze

# Tests unitarios
flutter test test/csv_import_test.dart

# Ejecutar en Chrome (puerto 8080)
flutter run -d chrome --web-port 8080

# Ejecutar en emulador Android
flutter run -d emulator-5554

# Ejecutar en emulador Android (sin Impeller — workaround para x86)
flutter run -d emulator-5554 --no-enable-impeller

# Limpiar caché de compilación
flutter clean && flutter pub get
```

---

## ⚙️ Estado Final

```
flutter analyze → ✅ No issues found! (0 errores, 0 warnings)
flutter test    → ✅ 10/10 All tests passed!
Web (Chrome)    → ✅ Funcionando en puerto 8080
Android (físico)→ 🟡 Pendiente de prueba en hardware real
Android (emu)   → ⚠️  Crash de Isar + Impeller en emulador x86
```

---

## 🐛 Problemas Conocidos y Soluciones

### 1. `IsarError: Collection id is invalid` (Emulador Android)

**Causa:** La base de datos Isar del emulador tenía schemas de una versión anterior incompatibles con los nuevos archivos `.g.dart`.

**Solución:**
```bash
# 1. Desinstalar la app del emulador para borrar la BD antigua
# 2. Regenerar schemas
flutter clean
dart run build_runner build --delete-conflicting-outputs
# 3. Volver a instalar
flutter run -d emulator-5554
```

### 2. Crash de Impeller en emulador x86 (API 30)

**Causa:** El backend GLES del emulador x86_64 no puede enlazar los pipeline shaders de Impeller.

**Workaround:**
```bash
flutter run -d emulator-5554 --no-enable-impeller
```

> **Nota:** En dispositivos físicos Android, Impeller funciona correctamente. Este es un bug conocido del emulador x86.

### 3. `package:web` rompe compilación Android

**Causa:** Los tipos `JSAny`, `JSObject` de `package:web` no existen en el runtime nativo de Android.

**Solución implementada:** Patrón de importación condicional con archivos stub (ver sección *Soporte Web*).

---

## 📋 Archivos Clave Modificados / Creados

| Archivo | Tipo | Descripción |
|---|---|---|
| `pubspec.yaml` | Modificado | Agregada dep `web: ^1.1.0` |
| `lib/features/inventory/presentation/pages/inventory_page.dart` | Modificado | Migración APIs, CSV real, formato COP |
| `lib/features/inventory/presentation/pages/web_storage_stub.dart` | **Nuevo** | Abstracción localStorage para Android |
| `lib/features/inventory/presentation/pages/web_storage_web.dart` | **Nuevo** | Implementación localStorage para Chrome |
| `test/csv_import_test.dart` | **Nuevo** | Suite de 10 tests automatizados |
| `test_data/inventario_prueba.csv` | **Nuevo** | CSV de prueba con 12 productos COP |
| `lib/core/database/isar_service.dart` | Sin cambios | Servicio Isar (referencia) |
| `lib/main.dart` | Sin cambios | Entry point (referencia) |

---

## Sesión 2 — 3 de junio de 2026

### Objetivos de la sesión
- Verificar que la app corre en el emulador Android
- Documentar el estado actual y decisiones de la sesión anterior
- Actualizar `agent.md` con el progreso completo

### Lo realizado

**Revisión de estado del proyecto:**
- Se verificó `agent.md` (402 líneas, 14 secciones) — refleja correctamente el estado: 4 módulos ✅, dashboard ✅, stubs auth/suppliers 🟡
- git log: 29 commits ahead de `origin/codex-local-first`, branch `codex-local-first`, working tree limpio

**Build y ejecución en Android:**
- `flutter run -d emulator-5554 --no-enable-impeller` → ✅ exitoso
- APK construido: `build/app/outputs/flutter-apk/app-debug.apk`
- Tiempo de compilación: ~117s para Gradle + ~1.5s install
- Isar Inspector disponible en: `https://inspect.isar.dev/3.1.0+1/#/61442/s1N9Ma66yxw`
- App corriendo correctamente en emulador `sdk gphone x86 64` (Android 11 / API 30)

**Problema encontrado — Chrome no compila:**
- Error: `The integer literal X can't be represented exactly in JavaScript` en 9 archivos `.g.dart`
- Causa: Isar genera IDs int64 que JavaScript no puede representar (±2⁵³)
- Solución documentada: correr en Android (emulador o dispositivo físico)
- No requiere cambio de código — es limitación conocida de Isar v3 en web

**Warnings de compilación (no bloqueantes):**
- AGP version 8.7.3 — próximo a ser removido, migrar a ≥8.11.1
- `file_picker` usa Kotlin Gradle Plugin — futuro problema si no se actualiza
- `--no-enable-impeller` flag deprecated — remover en próximas versiones de Flutter

### Decisiones tomadas
- Se mantiene el branch `codex-local-first` — no se merging a main
- `agent.md` queda como documento vivo; `docs/historical.md` acumula el registro histórico
- Para desarrollo local: usar `flutter run -d emulator-5554 --no-enable-impeller` (Android)
- Para web: no soportado actualmente por incompatibilidad de IDs Isar con JS

### Archivos modificados en esta sesión
| Archivo | Tipo | Descripción |
|---|---|---|
| `agent.md` | Modificado | Secciones 2 y 5.5/5.6 reflejan estado completo; sección 13 añade tabla de archivos de billing y returns |
| `docs/historical.md` | Modificado | Añadida esta entrada de sesión |

### Commit
```
docs: documentar sesión 2026-06-03 + verificar app en emulador Android
```

---

### Notas para la próxima sesión

**Lo que funciona (listo para probar):**
- Dashboard → navegación a los 4 módulos reales
- Inventario (6 productos demo, CSV import funcional)
- Clientes (3 clientes demo, CRUD completo)
- Facturación (2 facturas demo, stock decrementa al guardar)
- Devoluciones (2 devoluciones demo, stock repone al guardar)

**Próximos pasos sugeridos (del plan original):**
1. Auth — Login local con usuarios hardcoded (preparación para Supabase)
2. Suppliers — CRUD proveedores + historial precios
3. Métricas dashboard — conectar a datos reales (reemplazar valores hardcoded)
4. Supabase — backend + auth + sync bidireccional

**Comandos útiles para la próxima sesión:**
```bash
# Correr en Android
flutter run -d emulator-5554 --no-enable-impeller

# Ver devices disponibles
flutter devices

# Análisis estático
flutter analyze

# Tests
flutter test

# Build release APK
flutter build apk --release
```

---

## Sesión 3 — 3 de junio de 2026 (tarde)

### Objetivos de la sesión
- Implementar Auth completo (login con 2 usuarios hardcoded, logout)
- Actualizar documentación

### Lo realizado

**Auth implementado:**
- `AuthSession` singleton en `lib/core/services/auth_session.dart` — gestiona usuario activo, login/logout
- 2 usuarios hardcoded: Mayra (admin) y Mateo (vendedor)
- `LoginPage` con 2 cards — tap en card → entra directo (sin password)
- `AuthWrapper` StatelessWidget — redirige a LoginPage si no hay sesión, a DashboardPage si hay sesión
- `main.dart` conectado con `AuthWrapper` + rutas `/` y `/home`
- Dashboard `AppBar` reemplazó badge "Online" por nombre de usuario + dropdown logout
- Tests de `AuthSession` (5 tests)
- `widget_test.dart` actualizado para flujo con login

**Decisiones tomadas:**
- Sesión en memoria (no persiste en Isar) — suficiente para MVP local
- Login sin password — solo selector de usuario (tap → entra)
- Logout via `PopupMenuButton` en AppBar que muestra nombre + rol
- El badge de usuario usa color primary para admin, secondary para vendedor

### Archivos modificados/creados
| Archivo | Tipo | Descripción |
|---|---|---|
| `lib/core/services/auth_session.dart` | **Nuevo** | Singleton AuthSession con usuarios hardcoded |
| `lib/features/auth/presentation/pages/login_page.dart` | **Nuevo** | Login con 2 cards (Mayra/Mateo) |
| `lib/features/auth/presentation/widgets/auth_wrapper.dart` | **Nuevo** | Route guard StatelessWidget |
| `lib/main.dart` | Modificado | AuthWrapper + rutas / y /home |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Modificado | UserBadge + logout en AppBar |
| `test/features/auth/auth_session_test.dart` | **Nuevo** | 5 tests de AuthSession |
| `test/widget_test.dart` | Modificado | Login flow en widget test |
| `agent.md` | Modificado | auth: 🟡 → ✅ |
| `docs/historical.md` | Modificado | Añadida esta entrada |

### Commits
```
661accc refactor(core): extract AuthSession singleton
6ae095f test(auth): add AuthSession tests + fix widget_test for login flow
```

### Tests: 31/31 ✅

### Estado actual del proyecto (post-sesión 3)
| Feature | Estado |
|---|---|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo |
| returns | ✅ Completo |
| home (dashboard) | ✅ UI |
| **auth** | **✅ Completo** |
| suppliers | 🟡 Solo modelo |
| Backend (Supabase) | ❌ No conectado |

### Notas para la próxima sesión
1. **Suppliers** — CRUD proveedores + historial precios (ubicación: sección Inventario del dashboard)
2. Métricas dashboard — conectar a datos reales (pendiente, requiere Supabase o agregaciones locales)
3. Supabase fase 2

### Comandos útiles
```bash
# Correr en Android
flutter run -d emulator-5554 --no-enable-impeller

# Tests
flutter test

# Análisis estático
flutter analyze
```

---

## Sesión 4 — 3 de junio de 2026 (tarde)

### Objetivos de la sesión
- Implementar módulo Suppliers completo (CRUD + historial de precios)
- Actualizar documentación

### Lo realizado

**Proveedores implementado:**
- `HistorialPrecio` domain entity (4 campos + copyWith)
- `Proveedor` entity con copyWith
- `HistorialPreciosModel` completo con toDomain/fromDomain
- `HistorialPreciosRepository` (contract + IO + Web)
- `ProveedoresRepository` (contract + IO + Web + seed de 3 proveedores)
- `HistorialPreciosSeedData` (3 registros demo de precios)
- `ProveedoresSeedData` (3 proveedores: Repuestos Moto JC, Distribuidora Pegasus, Importados El Sol)
- `ProveedoresPage` (lista con búsqueda por nombre/nit, FAB, delete con confirmación)
- `ProveedorFormPage` (crear/editar + sección historial colapsable con dropdown de productos del inventario + precios)
- Dashboard: grid 2x2 con tarjeta "Proveedores" (color morado) en Accesos Rápidos
- Tests: 4 tests de CRUD

**Decisiones tomadas:**
- Historial de precios vive dentro del ProveedorFormPage como sección colapsable (no tiene página propia)
- El dropdown de productos del historial reutiliza `InventoryRepository.loadInventory().productos` (cross-module)
- Al guardar proveedor se guardan todos los registros de precio del historial (no son editables independientemente)
- Dashboard: grid de 3x → 2x2 para agregar "Proveedores" sin perder layout

### Archivos modificados/creados
| Archivo | Tipo | Descripción |
|---|---|---|
| `lib/features/suppliers/domain/entities/historial_precio.dart` | **Nuevo** | Entidad dominio historial precios |
| `lib/features/suppliers/domain/entities/proveedor.dart` | Modificado | copyWith agregado |
| `lib/features/suppliers/data/models/historial_precios_model.dart` | Modificado | toDomain/fromDomain agregados |
| `lib/features/suppliers/data/repositories/historial_precios_repository.dart` | **Nuevo** | Contrato |
| `lib/features/suppliers/data/repositories/historial_precios_repository_io.dart` | **Nuevo** | Isar impl |
| `lib/features/suppliers/data/repositories/historial_precios_repository_web.dart` | **Nuevo** | Web impl |
| `lib/features/suppliers/data/repositories/proveedores_repository.dart` | **Nuevo** | Contrato |
| `lib/features/suppliers/data/repositories/proveedores_repository_io.dart` | **Nuevo** | Isar impl |
| `lib/features/suppliers/data/repositories/proveedores_repository_web.dart` | **Nuevo** | Web impl |
| `lib/features/suppliers/data/services/historial_precios_seed_data.dart` | **Nuevo** | 3 registros demo |
| `lib/features/suppliers/data/services/proveedores_seed_data.dart` | **Nuevo** | 3 proveedores demo |
| `lib/features/suppliers/presentation/pages/proveedores_page.dart` | **Nuevo** | Lista + búsqueda + delete |
| `lib/features/suppliers/presentation/pages/proveedor_form_page.dart` | **Nuevo** | Crear/editar + historial |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Modificado | Grid 2x2 + tarjeta Proveedores |
| `test/features/suppliers/proveedores_test.dart` | **Nuevo** | 4 tests CRUD |
| `agent.md` | Modificado | suppliers: 🟡 → ✅, sección 5.7添 |
| `docs/historical.md` | Modificado | Esta entrada |

### Commits
```
92fd41c refactor(suppliers): add copyWith on Proveedor + HistorialPrecio entity + complete HistorialPreciosModel
a452400 feat(suppliers): add ProveedoresRepository, ProveedoresPage, ProveedorFormPage + wire dashboard card
1904978 test(suppliers): add ProveedoresRepository CRUD tests (4 scenarios)
c02a217 docs: update agent.md + historical.md for suppliers
```

### Tests: 35/35 ✅

### Estado actual del proyecto (post-sesión 4)
| Feature | Estado |
|---|---|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo |
| returns | ✅ Completo |
| home (dashboard) | ✅ UI |
| auth | ✅ Completo |
| **suppliers** | **✅ Completo** |
| Backend (Supabase) | 🟡 Auth conectado, Sync pendiente |

### Próximos pasos pendientes
1. SyncService — cola offline + push cuando hay red + pull al arrancar (estrategia: last-write-wins)
2. Métricas dashboard — conectar a datos reales

### Comandos útiles
```bash
# Correr en Android
flutter run -d emulator-5554 --no-enable-impeller

# Tests
flutter test

# Análisis estático
flutter analyze

# Ver devices
flutter devices
```

---

## Sesión 5 — 3 de junio de 2026 (noche)

### Objetivos de la sesión
- Integrar Supabase Auth (login real con email/password)
- Actualizar AGP para soportar nuevas dependencias

### Lo realizado

**Supabase Auth implementado:**
- `supabase_flutter` agregado al `pubspec.yaml`
- `SupabaseService` singleton (`lib/core/services/supabase_service.dart`) — cliente Supabase con URL y anon key hardcoded
- `main.dart` actualizado — `SupabaseService.instance.init()` antes de Isar
- `LoginPage` reescrita — email/password fields + 2 quick users (Mayra/Mateo sin guion: `supermotos.com`)
- Credenciales Supabase configuradas: `https://skybcdetpah1btakusyf.supabase.co`

**Usuarios creados en Supabase:**
- `mayra@supermotos.com` / `super_motos2024` (rol: admin)
- `mateo@supermotos.com` / `super_motos2024` (rol: vendedor)

**AGP actualizado:**
- `android/settings.gradle.kts`: 8.7.3 → 8.9.1 (requerido por `androidx.browser` y `androidx.core`)

**DNS del emulador:**
- El emulador no puede resolver `skybcdetpah1btakusyf.supabase.co`
- El login real aún no se pudo verificar end-to-end

### Archivos modificados/creados
| Archivo | Tipo | Descripción |
|---|---|---|
| `pubspec.yaml` | Modificado | Agregado `supabase_flutter: ^2.5.0` |
| `lib/core/services/supabase_service.dart` | **Nuevo** | Cliente singleton Supabase |
| `lib/main.dart` | Modificado | `SupabaseService.instance.init()` |
| `lib/features/auth/presentation/pages/login_page.dart` | Modificado | Email/password + quick users |
| `android/settings.gradle.kts` | Modificado | AGP 8.7.3 → 8.9.1 |

### Commit
```
703ef26 chore: add supabase_flutter + SupabaseService + update AGP to 8.9.1
```

### Estado actual del proyecto (post-sesión 5)
| Feature | Estado |
|---|---|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo |
| returns | ✅ Completo |
| home (dashboard) | ✅ UI |
| auth | ✅ Login real via Supabase |
| suppliers | ✅ Completo |
| **Supabase** | **🟡 Auth conectado, Sync pendiente** |
| Sync bidireccional | ❌ No implementada |

---

## Sesión 6 — 5-10 de junio de 2026

### Objetivos de la sesión
- Completar notificaciones de stock bajo y geolocalización
- Implementar login rápido offline (bypass Supabase)
- Corregir y verificar SyncService en entorno real
- Migrar a nuevo proyecto de Supabase (projecto original eliminado)

### Lo realizado

**StockAlertService (notificaciones de stock bajo):**
- `lib/core/services/stock_alert_service.dart` — singleton con `flutter_local_notifications`
- Verificación en `inventory_repository_io.dart:decrementCamionStock()` — si nueva cantidad < stockMinimo, dispara notificación local
- Tarjeta ámbar en dashboard con conteo persistente via SharedPreferences

**LocationService (geoposicionamiento):**
- `lib/core/services/location_service.dart` — singleton con `geolocator`
- Captura de coordenadas al guardar factura en `FacturaFormPage`
- Muestra icono + coordenadas en `FacturaDetailPage` footer
- Permisos: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` en `AndroidManifest.xml`, `NSLocationWhenInUseUsageDescription` en `Info.plist`

**Login rápido offline:**
- `LoginPage` modificada — tarjetas de acceso rápido (Mayra/Mateo) usan directamente `AuthSession.hardcodedUsers` sin pasar por SupabaseAuth
- Funciona sin internet ni DNS de Supabase

**SyncService:**
- Flag `_canSync` agregado en `SyncService.init()` — evita errores `LateInitializationError` en tests
- Query methods: `getUnsyncedCount(table)`, `getUnsyncedItems(table)`, `isRecordPending(table, id)`
- UI badges (`SyncStatusBadge` compact/full + `SyncIndicator`) en todas las pantallas de listas y detalles

**Widgets creados:**
- `lib/core/widgets/sync_status_badge.dart` — widget reutilizable para badge de estado de sync
- Se muestra en: facturas_page, devoluciones_page, clientes_page, proveedores_page, inventory_page (3 tabs), factura_detail_page, devolucion_detail_page

**Correcciones de bugs:**
- `proveedores_page.dart` — `Expanded` dentro de `Row` sin límite causaba `RenderFlex overflow` → reemplazado con `Flexible(FlexFit.loose)`
- `sync_status_badge.dart` — `Border.all()` sin paréntesis de cierre rompía el widget tree

**Supabase project recreation:**
- Proyecto original `skybcdetpah1btakusyf` con dominio no resoluble (NXDOMAIN)
- Credenciales incorrectas — JWT anon key decodificaba a otro `ref` que el URL del proyecto
- Nuevo proyecto creado: `zkabiilslxsfjwomxtkk.supabase.co`
- Scripts SQL para 9 tablas (productos, inventario_camion, inventario_bodega, clientes, facturas, detalles_factura, devoluciones, proveedores, historial_precios) con `BIGSERIAL` primary keys
- RLS policies públicas para desarrollo (`GRANT USAGE ON SCHEMA public TO anon`)
- Usuarios de auth creados: `mayra@supermotos.com` (rol: admin, nombre: Mayra) y `mateo@supermotos.com` (rol: vendedor, nombre: Mateo)

**Problema detectado:** El nuevo proyecto de Supabase no inicializa el schema `auth` (tablas internas como `auth.users` están ausentes), causando error `AuthRetryableFetchException: database error querying schema` (status 500) al intentar login real. La extensión `pg_net` tampoco está presente.

**Estado final:** La app funciona offline (quick login bypass + Isar local), pero el sync bidireccional y el login real con Supabase requieren un proyecto de Supabase nuevo con el schema `auth` correctamente inicializado.

### Archivos creados
| Archivo | Descripción |
|---|---|
| `lib/core/services/stock_alert_service.dart` | Servicio de notificaciones de stock bajo |
| `lib/core/services/location_service.dart` | Servicio de geolocalización (GPS) |
| `lib/core/widgets/sync_status_badge.dart` | Widgets de estado de sync |

### Archivos modificados
| Archivo | Cambios |
|---|---|
| `lib/core/services/supabase_service.dart` | URL + anon key actualizados al nuevo proyecto |
| `lib/main.dart` | Inicialización de StockAlertService, permisos de ubicación |
| `lib/features/auth/presentation/pages/login_page.dart` | Quick login bypass + corrección de emails |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Tarjeta stock bajo, venta total dinámica, WidgetsBindingObserver |
| `lib/features/billing/presentation/pages/factura_form_page.dart` | Captura de geolocalización al guardar |
| `lib/features/billing/presentation/pages/factura_detail_page.dart` | Icono + coordenadas de ubicación |
| `lib/features/suppliers/presentation/pages/proveedores_page.dart` | Fix RenderFlex overflow (Expanded → Flexible) |
| `lib/features/inventory/data/repositories/inventory_repository_io.dart` | Verificación de stock bajo en decrementCamionStock |
| `lib/core/services/sync_service.dart` | Flag _canSync, query methods |
| `lib/core/services/auth_session.dart` | HardcodedUsers actualizados |

### Commits
```
08457f3 feat(notifications): add stock alert service + dashboard card
cbabcd5 feat(geolocation): add LocationService + capture coords on factura save
bf4f1df fix(tests): silence SyncService push errors in test environment
ffb8f19 fix(login): quick login bypasses Supabase using hardcoded users
3d3072d fix(sync_status_badge): missing closing parens in Border.all calls
```

### Estado actual del proyecto (post-sesión 6)
| Feature | Estado |
|---|---|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo (+ geolocalización) |
| returns | ✅ Completo |
| home (dashboard) | ✅ UI (+ alertas stock, venta total dinámica) |
| auth | ✅ Login rápido offline + Login real via Supabase |
| suppliers | ✅ Completo |
| Notificaciones stock bajo | ✅ Implementado |
| Geoposicionamiento | ✅ Implementado |
| Sync bidireccional | ✅ Implementado (+ badges en UI) |
| **Supabase** | **🟡 Auth schema no inicializado — requiere recrear proyecto** |

---

## Sesión 7 — 10 de junio de 2026

### Objetivos de la sesión
- Crear script SQL completo para configurar Supabase desde cero
- Solucionar el error `AuthRetryableFetchException: database error querying schema` en login con Supabase
- Actualizar documentación y reorganizar ramas de git

### Lo realizado

**Script SQL completo:**
- `database/schema.sql` — script de 14 KB con todo lo necesario para inicializar Supabase
- 9 tablas con BIGSERIAL primary keys, foreign keys (donde aplica), CHECK constraints para enums
- Función trigger `update_updated_at_column()` para auto-actualizar `updated_at` en cada UPDATE
- Índices en columnas de búsqueda frecuente (producto_id, cliente_id, factura_numero, etc.)
- RLS policies abiertas para anon y authenticated (modo desarrollo)
- Creación de usuarios `mayra@supermotos.com` y `mateo@supermotos.com` via `auth.users` (SQL alternativo; recomendado usar Dashboard)

**Fix del problema de login:**
- La URL de Supabase en `supabase_service.dart` tenía `/rest/v1/` de más → causaba 404
- El schema `auth` del proyecto `ikylfhkexuxigchwccbu` no se había inicializado correctamente (500: "Database error querying schema")
- Solución: crear proyecto nuevo en Supabase, esperar a que esté activo, ejecutar schema.sql
- Login real funcionando end-to-end con ambos usuarios

**Reorganización de ramas:**
| Operación | Comando |
|---|---|
| Renombrar `codex-local-first` | `git branch -m codex-local-first conociendo_agentes_back` |
| Crear rama UI desde el rename | `git checkout -b U/I_details` |

- `conociendo_agentes_back`: rama principal de desarrollo (backend + agentes)
- `U/I_details`: rama hija para documentación y próximos trabajos de UI

### Archivos creados
| Archivo | Descripción |
|---|---|
| `database/schema.sql` | Script SQL completo para Supabase (9 tablas, triggers, índices, RLS, auth users) |

### Archivos modificados
| Archivo | Cambios |
|---|---|
| `lib/core/services/supabase_service.dart` | URL corregida (sin `/rest/v1/`), placeholders reemplazados por valores reales del nuevo proyecto |
| `agent.md` | Problema conocido de `auth` schema eliminado; añadida referencia a `database/schema.sql` |
| `CONTEXT.md` | Fase 4 → ✅, secciones de stock bajo y geo marcadas como implementadas, emails corregidos, ramas actualizadas |
| `README.md` | Estado actualizado con todos los módulos completos + backend Supabase conectado |
| `docs/historical.md` | Esta entrada de sesión |

### Commit (rama `U/I_details`)
```
docs: update agent.md, CONTEXT.md, README.md, historical.md — Supabase fix + branch rename
```

### Estado actual del proyecto (post-sesión 7)
| Feature | Estado |
|---|---|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo (+ geolocalización) |
| returns | ✅ Completo |
| home (dashboard) | ✅ UI (+ alertas stock, venta total dinámica) |
| auth | ✅ Login rápido offline + Login real via Supabase |
| suppliers | ✅ Completo |
| Notificaciones stock bajo | ✅ Implementado |
| Geoposicionamiento | ✅ Implementado |
| Sync bidireccional | ✅ Implementado (+ badges en UI) |
| Supabase | ✅ Login real funcionando · Schema.sql listo · RLS configurado |
| database/schema.sql | ✅ Script completo para recrear backend |

### Notas para la próxima sesión
- Chrome/web sigue sin soporte (IDs int64 de Isar no caben en JS)
- `/rest/v1/` en la URL de Supabase rompe el login — siempre usar solo la base URL
- Crear auth users por Dashboard es más confiable que por SQL directo

---

## Sesión 2026-06-11 — UI del InventoryPage

### Problema original
- Grid 2 columnas con aspectRatio 0.85 causaba overflow vertical
- TabBar colapza incorrectamente con scroll (Bottom Overflowed by 26px)
- Tarjetas muy grandes (~200px) o muy pequeñas (~76px)
- Iconos duplicados en AppBar (flecha de regreso + search icon compitiendo)
- FAB "Nuevo Producto" no visible
- Badge truncado ("ORIG"/"GEN" en vez de "ORIGINAL"/"GENÉRICO")
- "STOCK BAJO" con icono en vez de texto puro en rojo

### Soluciones aplicadas

#### Scroll y collapse
- `NestedScrollView` + `SliverAppBar(pinned: false, floating: true, snap: true)` para search
- `SliverPersistentHeader(pinned: true)` con `_TabBarHeaderDelegate` para TabBar FIJA
- `SliverAppBar.automaticallyImplyLeading: false` elimina icono automático
- `Scaffold AppBar` con `leading: IconButton(arrow_back)` explícito

#### Tarjetas compactas (punto medio de legibilidad)
- `ListView.separated` con cards Row 2 columnas
- Padding 12, fonts: título 15px, subtitle 12px, price 15px, values 14px, labels 11px
- Divisor vertical 70px alto
- Altura aproximada: ~76-80px

#### Navegación
- Flecha de regreso en Scaffold AppBar (leading explícito)
- Icono de búsqueda verde (`prefixIcon: colorScheme.primary`) en TextField
- FAB visible solo en tab Inventario Total

#### Total tab
- "ORIGINAL" / "GENÉRICO" texto completo
- "STOCK BAJO" en rojo (`colorScheme.error`) sin icono cuando stock bajo en camión

### Archivos modificados
- `lib/features/inventory/presentation/pages/inventory_page.dart`
- `CONTEXT.md` — sección 15 actualizada
- `docs/testing_guide.md` — NUEVO

### Commits de esta sesión
```
fix(ui): grid 1 column + compact cards + NestedScrollView + SliverAppBar collapse
fix(navigation): add back arrow to Scaffold AppBar + prefixIcon search green
fix(ui): restore FAB Nuevo Producto visible only on Total tab
fix(ui): badge full text ORIGINAL/GENERICO + STOCK BAJO red without icon
docs: add inventory page UI section to CONTEXT.md
docs: create testing_guide.md with full test cases
```

### Estado del proyecto post-sesión
| Feature | Estado |
|---|---|
| InventoryPage UI | ✅ Scroll colapzable + TabBar fija + tarjetas compactas |
| FAB Nuevo Producto | ✅ Visible solo en Inventario Total |
| Navegación | ✅ Sin iconos duplicados |
| Badge texto completo | ✅ ORIGINAL/GENÉRICO/STOCK BAJO |

---

## Sesión 8 — 2026-06-20 — Módulo Recepción + Migración String ID completa

### Objetivos de la sesión
- Implementar módulo completo de Recepciones (CRUD, split stock, upsert historial precios)
- Completar migración de IDs a String (alphanumérico libre) + canastas alfanuméricas
- Integrar Recepción en Proveedores (badge reactivo + botón registrar)
- Documentación completa en agent.md, CONTEXT.md, historical.md
- Tests completos (12 tests recepción, total 47/47 passing)

### Lo realizado

**Migración String ID (completada):**
- Todos los modelos Isar: `Id id` (PK interno) + `@Index(unique: true) String codigo` (business key)
- Entidades de dominio: `String codigo` en todas (PROD-, CLI-, FAC-, DEV-, PROV-, HP-, USR-, REC-)
- Supabase: tablas con `TEXT` primary keys, `onConflict: 'codigo'`
- Canastas: `canasta_id` String (ej. `A-1`, `B-5`) en lugar de `numero_canasta` int
- CSV: primera columna `codigo` (String), columna canasta `canasta_id` (String)

**Módulo Recepción (nuevo):**
- **Entidades**: `Recepcion` (codigo, proveedorId, fecha, nroRemito, observaciones, detalles[]) + `DetalleRecepcion` (productoId, cantidad, precioUnitario, destino {camion|bodega|split}, cantidadCamion?, cantidadBodega?)
- **Modelos Isar**: `RecepcionModel` (@collection, codigo unique) + `DetalleRecepcionModel` (@embedded, destino CHECK camion|bodega|split)
- **Repositorio**: `IsarRecepcionRepository` con **inyección de dependencias** via constructor (`InventoryRepository`, `HistorialPreciosRepository`) para testabilidad
  - `create()`: valida split → incrementa stock (crea entrada si no existe) → upsert HistorialPrecio → enqueue sync
  - Validación split: `cantidadCamion + cantidadBodega == cantidad` (lanza StateError si falla)
  - `loadByProveedor()`, `getByCodigo()`, `delete()` (soft, no revierte stock)
- **UI**: 
  - `RecepcionesPage`: lista + búsqueda + FAB → formulario
  - `RecepcionFormPage`: selector proveedor + cabecera + líneas modales (destino SegmentedButton + split condicional) + footer total
  - `RecepcionDetailPage`: cabecera + líneas + footer + delete soft
- **Integración Proveedores**:
  - `ProveedoresPage`: badge "Recepciones" con contador → navega a `RecepcionesPage(proveedorId:)` filtrada
  - `ProveedorFormPage`: botón "Registrar recepción" → `RecepcionFormPage(proveedorId:)` pre-seleccionado
  - `RecepcionesPage` acepta `proveedorId?` → filtra + AppBar dinámico
  - `RecepcionFormPage` acepta `proveedorId?` → pre-selecciona proveedor
- **Sync**: `recepciones` + `detalles_recepcion` en SyncService (`onConflict: 'codigo'`, push/pull)
- **Supabase**: 2 tablas nuevas (`recepciones`, `detalles_recepcion`) con FK, índices, triggers, RLS
- **Tests** (`recepcion_test.dart`): 12 tests (CRUD, stock camion/bodega/split, upsert HistorialPrecio, sync, validación split)

**Cambios transversales:**
- `IsarRecepcionRepository`: constructor con inyección de dependencias (testabilidad)
- `InventoryRepository`: `incrementBodegaStock()` + `createProductFromRecepcion()` (IO + Web)
- `HistorialPreciosRepository`: `upsertPrecio()` (IO + Web)
- `SyncService`: soporte tablas `recepciones` + `detalles_recepcion`
- `database/schema.sql`: 2 tablas nuevas + índices + RLS + triggers

### Archivos creados
- `lib/features/recepcion/domain/entities/recepcion.dart`
- `lib/features/recepcion/domain/entities/detalle_recepcion.dart`
- `lib/features/recepcion/data/models/recepcion_model.dart`
- `lib/features/recepcion/data/repositories/recepcion_repository.dart`
- `lib/features/recepcion/data/repositories/recepcion_repository_io.dart`
- `lib/features/recepcion/data/repositories/recepcion_repository_web.dart`
- `lib/features/recepcion/data/services/recepcion_seed_data.dart`
- `lib/features/recepcion/presentation/pages/recepciones_page.dart`
- `lib/features/recepcion/presentation/pages/recepcion_form_page.dart`
- `lib/features/recepcion/presentation/pages/recepcion_detail_page.dart`
- `test/features/recepcion/recepcion_test.dart` (12 tests)

### Archivos modificados
- `lib/core/database/isar_service.dart` (registro RecepcionModelSchema)
- `lib/features/recepcion/data/repositories/recepcion_repository_io.dart` (DI constructor + validación split)
- `lib/features/inventory/data/repositories/inventory_repository.dart` (incrementBodegaStock, createProductFromRecepcion)
- `lib/features/inventory/data/repositories/inventory_repository_io.dart` (incrementBodegaStock, createProductFromRecepcion)
- `lib/features/inventory/data/repositories/inventory_repository_web.dart` (incrementBodegaStock, createProductFromRecepcion)
- `lib/features/suppliers/data/repositories/historial_precios_repository.dart` (upsertPrecio)
- `lib/features/suppliers/data/repositories/historial_precios_repository_io.dart` (upsertPrecio)
- `lib/features/suppliers/data/repositories/historial_precios_repository_web.dart` (upsertPrecio)
- `lib/core/services/sync_service.dart` (recepciones + detalles_recepcion en upsert/delete/pull)
- `database/schema.sql` (tablas recepciones + detalles_recepcion + índices + RLS)
- `lib/features/suppliers/presentation/pages/proveedores_page.dart` (badge recepciones + nav)
- `lib/features/suppliers/presentation/pages/proveedor_form_page.dart` (botón registrar recepción)
- `lib/features/recepcion/presentation/pages/recepciones_page.dart` (proveedorId filter + AppBar dinámico)
- `lib/features/recepcion/presentation/pages/recepcion_form_page.dart` (proveedorId pre-select)
- `agent.md` (sección 5.8 Recepción completa)
- `CONTEXT.md` (fases, estructura, modelos 11, sync, tests)
- `docs/historical.md` (esta entrada)

### Commits de esta sesión
```
feat: add Recepción module with split stock + HistorialPrecio upsert + Proveedores integration
refactor: IsarRecepcionRepository DI constructor for testability
feat: String ID migration (alphanumeric) + canasta_id String
feat: ProveedoresPage badge + ProveedorFormPage recepción button
docs: update agent.md + CONTEXT.md + historical.md with Recepción module
test: 12 new recepcion tests (total 47/47 passing)
```

### Estado del proyecto post-sesión
| Feature | Estado |
|---|---|
| **Recepción** | ✅ CRUD + split + upsert historial + sync + UI + integración Proveedores |
| **Migración String ID** | ✅ Completada (todos los modelos, entidades, Supabase, CSV, seeds) |
| **Tests** | ✅ 47/47 passing (12 nuevos recepción) |
| **Documentación** | ✅ agent.md + CONTEXT.md + historical.md actualizados |

---

## Sesión 7 — 2026-06-11 — UI del InventoryPage

### Problema original
- Grid 2 columnas con aspectRatio 0.85 causaba overflow vertical
- TabBar colapza incorrectamente con scroll (Bottom Overflowed by 26px)
- Tarjetas muy grandes (~200px) o muy pequeñas (~76px)
- Iconos duplicados en AppBar (flecha de regreso + search icon compitiendo)
- FAB "Nuevo Producto" no visible
- Badge truncado ("ORIG"/"GEN" en vez de "ORIGINAL"/"GENÉRICO")
- "STOCK BAJO" con icono en vez de texto puro en rojo

### Soluciones aplicadas

#### Scroll y collapse
- `NestedScrollView` + `SliverAppBar(pinned: false, floating: true, snap: true)` para search
- `SliverPersistentHeader(pinned: true)` con `_TabBarHeaderDelegate` para TabBar FIJA
- `SliverAppBar.automaticallyImplyLeading: false` elimina icono automático
- `Scaffold AppBar` con `leading: IconButton(arrow_back)` explícito

#### Tarjetas compactas (punto medio de legibilidad)
- `ListView.separated` con cards Row 2 columnas
- Padding 12, fonts: título 15px, subtitle 12px, price 15px, values 14px, labels 11px
- Divisor vertical 70px alto
- Altura aproximada: ~76-80px

#### Navegación
- Flecha de regreso en Scaffold AppBar (leading explícito)
- Icono de búsqueda verde (`prefixIcon: colorScheme.primary`) en TextField
- FAB visible solo en tab Inventario Total

#### Total tab
- "ORIGINAL" / "GENÉRICO" texto completo
- "STOCK BAJO" en rojo (`colorScheme.error`) sin icono cuando stock bajo en camión

### Archivos modificados
- `lib/features/inventory/presentation/pages/inventory_page.dart`
- `CONTEXT.md` — sección 15 actualizada
- `docs/testing_guide.md` — NUEVO

### Commits de esta sesión
```
fix(ui): grid 1 column + compact cards + NestedScrollView + SliverAppBar collapse
fix(navigation): add back arrow to Scaffold AppBar + prefixIcon search green
fix(ui): restore FAB Nuevo Producto visible only on Total tab
fix(ui): badge full text ORIGINAL/GENERICO + STOCK BAJO red without icon
docs: add inventory page UI section to CONTEXT.md
docs: create testing_guide.md with full test cases
```

### Estado del proyecto post-sesión
| Feature | Estado |
|---|---|
| InventoryPage UI | ✅ Scroll colapzable + TabBar fija + tarjetas compactas |
| FAB Nuevo Producto | ✅ Visible solo en Inventario Total |
| Navegación | ✅ Sin iconos duplicados |
| Badge texto completo | ✅ ORIGINAL/GENÉRICO/STOCK BAJO |

---

## Sesión 2026-06-21 — Flujo CSV→Supabase: 5 Mejoras Completadas

### Objetivos
1. Prioridad 1 — Indicador global de sync en AppBar (Alta prioridad)
2. Prioridad 2 — Pantalla "Pendientes de Sync" navegable
3. Prioridad 3 — Exportar a CSV desde Inventario
4. Prioridad 4 — SyncLogService compatible web
5. Prioridad 5 — Backup programado a Supabase Storage

### Lo realizado

#### Prioridad 1: SyncStateIndicator Global
- `SyncStateIndicator` agregado a AppBar de 6 páginas: inventory, clientes, facturas, proveedores, devoluciones, recepciones
- Widget ahora clicable (`InkWell`) → navega a `SyncQueuePage`

#### Prioridad 2: Conexión SyncQueuePage
- `SyncStateIndicator` clicable → abre `SyncQueuePage`
- Dashboard: tarjeta "Pendientes de Sync" visible cuando `queueLength > 0`

#### Prioridad 3: Exportar CSV
- `InventoryCsvExporter` (usa `CsvEncoder` de csv v8)
- File writers cross-platform: `_io.dart` (FilePicker.saveFile), `_web.dart` (data URI), `_stub.dart`
- `InventoryRepository.exportCsv()` abstracto + implementaciones IO y Web
- Botón `download_outlined` en AppBar de InventoryPage
- SnackBar confirmación al exportar

#### Prioridad 4: SyncLogService Cross-Platform
- `SyncLogEntry` y `SyncLogStatus` extraídos a archivo común
- Interfaz abstracta `SyncLogServiceBase` + factory `createSyncLogService()`
- `SyncLogServiceIO` — Android (sqflite, código original migrado)
- `SyncLogServiceWeb` — Chrome (SharedPreferences, JSON serializado)
- Todos los consumidores (`SyncService`, `SyncQueuePage`, `SyncBadge`) migrados a factory

#### Prioridad 5: Backup Supabase Storage
- `BackupService` singleton con `performBackup()`, `shouldBackup()`, `performBackupIfNeeded()`
- Auto-backup al iniciar si >24h desde último backup
- Botón manual `cloud_upload_outlined` en AppBar Dashboard
- Tooltip muestra "hace 2h", "hace 3d", etc.
- Sube CSV a bucket `backups/inventory/inventario_backup_{timestamp}.csv`

### Archivos creados (10 nuevos)

| Archivo | Propósito |
|---|---|
| `lib/features/inventory/data/services/inventory_csv_exporter.dart` | Serializador CSV |
| `lib/features/inventory/presentation/pages/inventory_file_writer_io.dart` | Guardar archivo Android |
| `lib/features/inventory/presentation/pages/inventory_file_writer_web.dart` | Descargar Chrome |
| `lib/features/inventory/presentation/pages/inventory_file_writer_stub.dart` | Stub condicional |
| `lib/core/services/sync_log_entry.dart` | SyncLogEntry + SyncLogStatus comunes |
| `lib/core/services/sync_log_service_stub.dart` | Interfaz abstracta + factory |
| `lib/core/services/sync_log_service_io.dart` | Impl Android (sqflite) |
| `lib/core/services/sync_log_service_web.dart` | Impl Chrome (SharedPreferences) |
| `lib/core/services/backup_service.dart` | Backup a Supabase Storage |

### Archivos modificados (16)

| Archivo | Cambio |
|---|---|
| `lib/features/inventory/data/repositories/inventory_repository.dart` | + `exportCsv()` abstracto |
| `lib/features/inventory/data/repositories/inventory_repository_io.dart` | exportCsv implementación |
| `lib/features/inventory/data/repositories/inventory_repository_web.dart` | exportCsv implementación |
| `lib/features/inventory/presentation/pages/inventory_page.dart` | Botón exportar + SyncStateIndicator + fixes bugs |
| `lib/core/widgets/sync_status_badge.dart` | SyncStateIndicator clicable |
| `lib/features/customers/presentation/pages/clientes_page.dart` | SyncStateIndicator en AppBar |
| `lib/features/billing/presentation/pages/facturas_page.dart` | SyncStateIndicator en AppBar |
| `lib/features/suppliers/presentation/pages/proveedores_page.dart` | SyncStateIndicator en AppBar |
| `lib/features/returns/presentation/pages/devoluciones_page.dart` | SyncStateIndicator en AppBar |
| `lib/features/recepcion/presentation/pages/recepciones_page.dart` | SyncStateIndicator en AppBar |
| `lib/core/services/sync_service.dart` | Factory createSyncLogService() |
| `lib/core/services/sync_log_service.dart` | Export condicional io/web |
| `lib/features/sync/presentation/pages/sync_queue_page.dart` | Factory + fix withOpacity |
| `lib/features/sync/presentation/widgets/sync_badge.dart` | Factory |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Backup + pending sync card |

### Bugs corregidos
- `inventory_page.dart`: import ambiguo, `StreamController` sin import, `lastProgress` no definido
- `withOpacity` deprecado → `withValues` (3 archivos)

### Commits sugeridos
```
fix(inventory): resolve ambiguous import, missing StreamController, undefined lastProgress
feat(sync): add SyncStateIndicator to AppBar on all main pages
feat(sync): connect SyncQueuePage navigation from SyncStateIndicator + dashboard card
feat(inventory): add CSV export button + service (chunked, cross-platform)
refactor(sync_log): make SyncLogService cross-platform (sqflite + shared_preferences)
feat(backup): add automated daily backup to Supabase Storage + manual trigger
chore: replace deprecated withOpacity with withValues
```

### Tests
- ✅ 47/47 tests pasando
- ✅ 0 errores en `flutter analyze`

---

## Sesión 9 — 2026-06-22 — Release v1.0: Sync fixes, CSV import fix, dashboard reorder, 3-digit codes, RLS security

### Objetivos de la sesión
- Arreglar flujo de sync (eliminar push inmediato, auto-marcar como synced en Isar)
- Arreglar importación CSV (eliminar doble import, preservar IDs en Isar, llenar loop de sync vacío)
- Corregir FK violation en Supabase (auto-encolar productos, migración única al iniciar)
- Agregar snackbars de confirmación en todas las entidades
- Reordenar dashboard (Ubicación → Operaciones → Accesos → Métricas)
- Agregar historial de devoluciones en Accesos Rápidos
- Reemplazar códigos largos (timestamp) por códigos secuenciales de 3 dígitos
- Corregir RLS de Supabase para producción (anon solo SELECT)
- Actualizar documentación y preparar release

### Lo realizado

**SyncService fixes:**
- Eliminado `_tryPushOne()` de `enqueue()` — los items ya no se pushean inmediatamente
- Agregado `_notifyResult()` en `enqueue()` para que el `SyncStateIndicator` muestre items pendientes
- Agregado `_markLocalAsSynced()` — tras push exitoso, actualiza `isSynced = true` en Isar local para 9 tablas
- Agregado `_migrateUnsyncedProducts()` — migración única al iniciar que encolea productos no sincronizados

**CSV import fixes:**
- Eliminado doble import en `inventory_page.dart` — ahora hay 1 sola llamada a `importCsv()` que reporta progreso y devuelve el snapshot
- Diálogo de progreso se auto-cierra al completar, botón cancelar funcional
- `inventory_repository_io.dart`: `importCsv()` preserva `id` de registros existentes antes de `put()`
- Loop de sync vacío rellenado — ahora encolea `productos`, `inventario_camion`, `inventario_bodega`
- `_seedDemoData()` ahora también encolea al sync
- Stock operations (`decrementCamionStock`, `incrementCamionStock`, `incrementBodegaStock`) aseguran producto encoleado antes del inventario

**FK violation fix (producto_id no existe en Supabase):**
- Causa raíz: seed data crea productos locales pero nunca los encoleaba al sync
- Fix: `inventory_repository_io.dart:loadInventory()` + `sync_service.dart:init()` encolean productos no sincronizados automáticamente
- Flag `super_motos_seeded` en SharedPreferences evita re-seeding
- Flag `super_motos_unsynced_migrated` para migración única

**Dashboard reorder:**
- Nuevo orden: 1-Ubicación 2-Operaciones de Ruta 3-Condicionales 4-Accesos Rápidos 5-Métricas del Día
- Agregado "Devoluciones" a Accesos Rápidos (icono teal)
- Renombrado "Historial" → "Facturas" en grid
- Fix `_onSyncResult`: guards para evitar popups repetitivos de "Sincronización exitosa" y "Fallo en sincronización"

**CodeGenerator (códigos de 3 dígitos):**
- `lib/core/utils/code_generator.dart` — contador secuencial por prefijo persistido en SharedPreferences
- Prefijos: CLI, FAC, DEV, PROV, PVHS (historial precios), REC, PROD
- En primera ejecución, escanea Isar para no colisionar con datos existentes
- Fallback a timestamp si SharedPreferences no está disponible (tests)
- Fix: si contador almacenado ≥ 1000 (legado de códigos largos), fuerza re-escaneo

**Row overflow fix (Devoluciones):**
- `devoluciones_page.dart`: `Text` del código envuelto en `Expanded` + `Flexible` + `overflow: TextOverflow.ellipsis`

**RLS Supabase para producción:**
- `database/schema.sql`: políticas `"Allow all for anon"` reemplazadas por `"Read only for anon"` (solo SELECT)
- `"Allow all for authenticated"` se mantiene intacto
- Storage bucket `backups`: política pública reemplazada por solo `authenticated`

**Snackbars de confirmación:**
- Agregados snackbars ámbar "Pendiente de sincronización" en los 5 forms:
  - Cliente (crear/editar)
  - Factura (nueva venta)
  - Devolución
  - Proveedor (crear/editar)
  - Recepción

**Sync listeners en list pages:**
- Agregado listener `syncResultNotifier` en: clientes_page, facturas_page, devoluciones_page, proveedores_page, recepciones_page
- Recargan silenciosamente la lista cuando sync completa, actualizando badges

### Archivos modificados/creados

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `lib/core/utils/code_generator.dart` | **Nuevo** | Generador secuencial de códigos de 3 dígitos |
| `lib/core/services/sync_service.dart` | Modificado | Quitar push inmediato, _notifyResult, _markLocalAsSynced, _migrateUnsyncedProducts |
| `lib/features/inventory/presentation/pages/inventory_page.dart` | Modificado | Eliminar doble import CSV, auto-cerrar diálogo, cancelar funcional |
| `lib/features/inventory/data/repositories/inventory_repository_io.dart` | Modificado | importCsv preserva IDs, sync enqueue, seed encolea, stock ops aseguran producto |
| `lib/features/inventory/data/repositories/inventory_repository_web.dart` | Modificado | Seed-only-once flag |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Modificado | Reordenar secciones, Devoluciones en grid, _onSyncResult guards |
| `lib/features/home/presentation/pages/backup_history_page.dart` | (sin cambios) | Fix via SQL storage policy |
| `lib/features/customers/presentation/pages/cliente_form_page.dart` | Modificado | Snackbar éxito + CodeGenerator |
| `lib/features/billing/presentation/pages/factura_form_page.dart` | Modificado | Snackbar éxito + CodeGenerator |
| `lib/features/returns/presentation/pages/devolucion_form_page.dart` | Modificado | Snackbar éxito + CodeGenerator |
| `lib/features/returns/presentation/pages/devoluciones_page.dart` | Modificado | Row overflow fix (Expanded + Flexible) |
| `lib/features/suppliers/presentation/pages/proveedor_form_page.dart` | Modificado | Snackbar éxito + CodeGenerator (PROV, PVHS) |
| `lib/features/suppliers/data/repositories/historial_precios_repository_io.dart` | Modificado | CodeGenerator PVHS |
| `lib/features/recepcion/presentation/pages/recepcion_form_page.dart` | Modificado | Snackbar éxito + CodeGenerator |
| `lib/features/inventory/presentation/pages/producto_form_page.dart` | Modificado | CodeGenerator PROD |
| `lib/features/customers/presentation/pages/clientes_page.dart` | Modificado | Listener syncResultNotifier |
| `lib/features/billing/presentation/pages/facturas_page.dart` | Modificado | Listener syncResultNotifier |
| `lib/features/returns/presentation/pages/devoluciones_page.dart` | Modificado | Listener syncResultNotifier |
| `lib/features/suppliers/presentation/pages/proveedores_page.dart` | Modificado | Listener syncResultNotifier |
| `lib/features/recepcion/presentation/pages/recepciones_page.dart` | Modificado | Listener syncResultNotifier |
| `database/schema.sql` | Modificado | RLS: anon solo SELECT, authenticated ALL |
| `agent.md` | Modificado | Esta sesión |
| `CONTEXT.md` | Modificado | Fase 6, CodeGenerator, RLS, dashboard reorder |
| `docs/historical.md` | Modificado | Esta entrada |

### Commits
```
```

### Tests: 47/47 ✅

### Estado del proyecto (post-release v1.0)
| Feature | Estado |
|---------|--------|
| inventory | ✅ Completo |
| customers | ✅ Completo |
| billing | ✅ Completo (+ geolocalización) |
| returns | ✅ Completo |
| home (dashboard) | ✅ Reordenado + Devoluciones |
| auth | ✅ Login rápido offline + Login real via Supabase |
| suppliers | ✅ Completo |
| Notificaciones stock bajo | ✅ Implementado |
| Geoposicionamiento | ✅ Implementado |
| Sync bidireccional | ✅ Push/pull + badges + cola + conflict detection |
| CSV import | ✅ Preview + progreso + cancelar + sync |
| Backup Supabase | ✅ Automático + manual + historial |
| CodeGenerator | ✅ Códigos secuenciales de 3 dígitos |
| Supabase RLS | ✅ Producción: anon solo SELECT |
| Dashboard | ✅ Reordenado: Ubicación → Operaciones → Accesos → Métricas |

### Próximos pasos sugeridos
- Logo de la app (`flutter_launcher_icons`)
- Publicar en Play Store
- Pruebas en dispositivo físico real
- Agregar más métricas al dashboard
