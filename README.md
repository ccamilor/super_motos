# Super Motos

Flutter app for inventory and sales operations of motorcycle parts.

## Current State

- Flutter is the main frontend.
- Isar is the local database on Android/native.
- Web uses local memory plus `localStorage` for imported CSV persistence.
- Inventory is now decoupled from the UI through a repository layer.
- No remote backend is connected yet.

## What It Does Today

- Opens a main dashboard.
- Lets the user enter the inventory module.
- Shows:
  - truck inventory,
  - warehouse inventory,
  - total inventory.
- Imports inventory from CSV files.
- Searches products by name or motorcycle compatibility.
- Persists imported CSV data on web across reloads.
- Seeds demo data when no inventory exists.

## Current Architecture

```text
UI (Flutter)
  -> InventoryRepository
      -> IsarInventoryRepository (Android/native)
      -> WebInventoryRepository (web/localStorage)
  -> InventoryCsvParser
  -> InventorySeedData
```

## Relevant Files

- `lib/main.dart`: app entry point.
- `lib/core/database/isar_service.dart`: Isar initialization.
- `lib/core/theme/app_theme.dart`: app theme.
- `lib/features/home/presentation/pages/dashboard_page.dart`: main dashboard.
- `lib/features/inventory/presentation/pages/inventory_page.dart`: inventory module.
- `lib/features/inventory/data/repositories/`: inventory repositories.
- `lib/features/inventory/data/services/`: CSV parser and demo seed.
- `test/csv_import_test.dart`: CSV flow tests.
- `test/widget_test.dart`: smoke test for the real app.
- `documentacion_refactor.md`: technical summary of the refactor.

## Requirements

- Flutter 3.44 or compatible.
- Dart 3.12 or compatible.
- For Android/native:
  - `isar`
  - `isar_flutter_libs`
  - `path_provider`
- For CSV import:
  - `csv`
  - `file_picker`
- For web:
  - `web`

## Install

```bash
flutter pub get
```

## Run

### Web

```bash
flutter run -d chrome --web-port 8080
```

### Android

```bash
flutter run -d emulator-5554
```

## Tests

```bash
flutter test test/csv_import_test.dart
flutter test test/widget_test.dart
```

## Generate Isar

If you change models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Inventory Flow

1. The screen loads inventory from the repository.
2. If there is no data, the demo seed is used.
3. On web, if a saved CSV exists, it is used.
4. When importing CSV:
   - the file is parsed,
   - data is stored,
   - the UI updates.

## Backend Note

Supabase is not connected yet.
The current strategy is local-first: local data first, remote backend later.

## Extra Docs

- [`documentacion_refactor.md`](./documentacion_refactor.md)

