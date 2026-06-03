---
name: flutter-dart-tools
description: Skill de opencode para automatizar comandos de Flutter y Dart en el proyecto Super Motos. Úsala cuando necesites correr análisis, tests, build_runner, regenerar schemas de Isar, o validar cambios antes de cerrar una tarea. Se activa en cualquier flujo que toque código Dart/Flutter del workspace.
---

# Flutter / Dart Tools — Super Motos

Skill de proyecto (no global) que define **qué comandos ejecutar y cuándo** dentro de `super_motos/`.

## Reglas duras del proyecto

1. **No añadir comentarios** al código (regla explícita del usuario).
2. **Regenerar schemas Isar** cada vez que se modifique un archivo `*_model.dart`:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Mantener `kIsWeb` como guard** en cualquier uso de `package:web` o APIs de browser.
4. **No romper la rama web** con tipos `JSAny`/`JSObject` — usar siempre el patrón de import condicional con `web_storage_stub.dart`.
5. **Formatos monetarios** siempre vía la función `_formatCOP` (no hardcodear `$ 35.000 COP` en widgets).

## Comandos disponibles

### Análisis estático

```bash
flutter analyze
```

- **Cuándo correrlo:** antes de marcar una tarea como completada, antes de pedir review, después de un cambio grande.
- **Criterio de éxito:** `No issues found! (0 errores, 0 warnings)`.

### Tests

```bash
flutter test test/csv_import_test.dart
flutter test test/widget_test.dart
flutter test test/features/inventory/inventory_test.dart
flutter test                       # corre toda la suite
```

- **Cuándo correrlos:** tras tocar `lib/features/inventory/`, `test_data/`, o cualquier modelo.
- **Criterio de éxito:** `All tests passed!` con 10/10 en `csv_import_test.dart`.

### Build runner (Isar)

```bash
dart run build_runner build --delete-conflicting-outputs
```

- **Cuándo correrlo:** **obligatorio** tras modificar `*_model.dart` (Producto, InventarioCamion, InventarioBodega, Cliente, Factura, Usuario, Proveedor, HistorialPrecios, Devolucion).
- **Síntoma de olvido:** errores tipo `IsarError: Collection id is invalid` en runtime.

### Ejecución

```bash
# Web
flutter run -d chrome --web-port 8080

# Android emulador (con workaround de Impeller)
flutter run -d emulator-5554 --no-enable-impeller

# Android emulador (sin workaround — puede crashear en x86)
flutter run -d emulator-5554
```

- **Recordatorio:** Impeller falla en emuladores x86 → usar `--no-enable-impeller`. En hardware físico funciona normal.

### Limpieza

```bash
flutter clean
flutter pub get
```

- **Cuándo correrla:** tras errores raros de Isar ("Collection id is invalid"), tras cambiar de rama, tras actualizar `pubspec.yaml`.

## Workflow recomendado por opencode

1. **Antes de empezar una tarea** → `flutter pub get` (asegurar deps).
2. **Durante cambios de modelo** → `dart run build_runner build --delete-conflicting-outputs`.
3. **Antes de declarar "listo"**:
   ```bash
   flutter analyze
   flutter test
   ```
4. **Si aparecen errores de Isar en runtime**:
   ```bash
   flutter clean
   dart run build_runner build --delete-conflicting-outputs
   flutter run -d emulator-5554 --no-enable-impeller
   ```

## Validación post-cambio (checklist)

Cuando el usuario pida cerrar una tarea que tocó `lib/`, verificar:

- [ ] `flutter analyze` → 0 issues
- [ ] `flutter test` → todos pasan
- [ ] Si se modificó algún `*_model.dart` → se regeneraron los `.g.dart`
- [ ] Si se añadió código que toca `package:web` → hay guard `kIsWeb` y/o import condicional
- [ ] Si se modificó formato de precio → se usa `_formatCOP`, no string literal
- [ ] `agent.md` se actualizó si cambió arquitectura, comandos, features o estado de algún módulo

## Archivos de referencia

- [`agent.md`](../../agent.md) — Estado actual del proyecto, arquitectura, decisiones
- [`docs/historical.md`](../../docs/historical.md) — Migraciones históricas, problemas resueltos
- `pubspec.yaml` — Dependencias (`isar`, `csv`, `file_picker`, `web`, `path_provider`)

## Anti-patrones (no hacer)

- ❌ Añadir `// comentarios` al código
- ❌ Modificar un `*_model.dart` sin regenerar `.g.dart`
- ❌ Usar `package:web` directamente sin guard de plataforma
- ❌ Hardcodear precios formateados en widgets
- ❌ Marcar tarea como completa sin correr `flutter analyze` + `flutter test`
- ❌ Asumir que la app corre en web con Isar inicializado (no funciona, Isar v3 no soporta web)
