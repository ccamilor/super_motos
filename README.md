# Super Motos

Flutter app for inventory and sales operations of motorcycle parts.

## Current State

- Flutter is the main frontend.
- Isar is the local database on Android/native.
- Supabase is the remote backend for auth and bidirectional sync.
- Web uses local memory plus `localStorage` for imported CSV persistence.
- All modules (inventory, customers, billing, returns, auth, suppliers) are complete.
- Stock alerts, geolocation, and offline sync queue are implemented.

## What It Does Today

- Full inventory management with 3 tabs (Truck, Warehouse, Total).
- Customer CRUD with credit limits and account status.
- Billing with line items, stock decrement, and geolocation capture.
- Returns processing with stock replenishment to truck baskets.
- Supplier management with purchase price history.
- Authentication with 2 users (admin + seller) and login via Supabase or offline quick access.
- Bidirectional sync with Supabase (offline queue, conflict detection).
- Low-stock push notifications.
- Imports inventory from CSV files.
- Searches products by name or motorcycle compatibility.
- Seeds demo data when no data exists.

## Current Architecture

```text
UI (Flutter)
  -> Per-Module Repository (abstract contract)
      -> Isar*Repository (Android/native)
      -> Web*Repository (web/localStorage)
  -> SupabaseService (remote backend)
  -> SyncService (offline queue + push/pull)
  -> StockAlertService (low-stock notifications)
  -> LocationService (GPS capture)
  -> InventoryCsvParser
  -> InventorySeedData
```

**Modules:** inventory · customers · billing · returns · auth · suppliers · home (dashboard)

## Relevant Files

- `lib/main.dart`: app entry point.
- `lib/core/services/supabase_service.dart`: Supabase client config.
- `lib/core/services/sync_service.dart`: offline sync queue + bidirectional push/pull.
- `lib/core/services/stock_alert_service.dart`: low-stock local notifications.
- `lib/core/services/location_service.dart`: GPS geolocation service.
- `lib/core/services/auth_session.dart`: current user session singleton.
- `lib/core/database/isar_service.dart`: Isar initialization.
- `lib/core/theme/app_theme.dart`: app theme.
- `lib/core/widgets/sync_status_badge.dart`: sync status badge widgets.
- `lib/features/home/presentation/pages/dashboard_page.dart`: main dashboard.
- `lib/features/inventory/presentation/pages/inventory_page.dart`: inventory module.
- `lib/features/inventory/data/repositories/`: inventory repositories.
- `lib/features/inventory/data/services/`: CSV parser and demo seed.
- `database/schema.sql`: complete Supabase schema script.
- `agent.md`: canonical project guide (architecture, state, commands).
- `docs/historical.md`: full development history.

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

Supabase is connected and fully functional for auth and sync.
The SQL schema is in `database/schema.sql` — run it in the Supabase SQL Editor
and update `lib/core/services/supabase_service.dart` with your project URL and anon key.

## Extra Docs

- [`agent.md`](./agent.md) — Guía canónica del proyecto (estado actual, arquitectura, comandos).
- [`docs/historical.md`](./docs/historical.md) — Registro histórico completo del desarrollo.
- [`CONTEXT.md`](./CONTEXT.md) — Contexto condensado para retomar el proyecto rápidamente.

