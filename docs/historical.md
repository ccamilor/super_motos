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
