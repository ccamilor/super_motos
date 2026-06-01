# Super Motos - Documento de Estado y Refactor

## Estado actual

- La app arranca en `lib/main.dart` y abre `DashboardPage`.
- `Isar` sigue siendo la base local en Android/nativo.
- En web, el inventario usa memoria local y `localStorage` para conservar el CSV importado.
- El módulo de inventario ya no habla directo con Isar desde la UI; ahora usa un repositorio.
- La lógica de parseo CSV está separada de la pantalla.
- La semilla demo está centralizada para reutilizarla entre web, Isar y tests.

## Cambios realizados

### Inventario

- Se creó `InventoryEntry` como modelo común de una fila de inventario.
- Se creó `InventoryCsvParser` para convertir CSV en entradas de inventario.
- Se creó `InventorySeedData` con la semilla demo unificada.
- Se creó `InventorySnapshot` para transportar el inventario completo.
- Se creó `InventoryRepository` como contrato único.
- Se implementó `IsarInventoryRepository` para Android/nativo.
- Se implementó `WebInventoryRepository` para web con `localStorage`.
- Se reescribió `InventoryPage` para consumir el repositorio.

### Tests

- Se reemplazó el test obsoleto del contador por un smoke test de la app real.
- Se reescribió el test de CSV para cubrir:
  - parseo del archivo real,
  - detección de encabezado,
  - mapeo de filas,
  - semilla demo,
  - formato COP.

### Dashboard

- Se ajustó el dashboard para no sugerir navegación real donde todavía no existe.

## Arquitectura actual

```text
UI (Flutter)
  -> InventoryRepository
      -> IsarInventoryRepository (Android / nativo)
      -> WebInventoryRepository (web / localStorage)
  -> InventoryCsvParser
  -> InventorySeedData
```

## Qué funciona hoy

- Abrir la app y entrar al dashboard.
- Entrar al inventario.
- Ver datos demo si no hay inventario cargado.
- Buscar productos por nombre o compatibilidad.
- Importar CSV y reemplazar el inventario.
- Persistir el CSV en web para mantenerlo entre recargas.

## Qué falta para la siguiente fase

- Integrar Supabase como backend remoto.
- Diseñar sincronización bidireccional.
- Definir estrategia de conflicto.
- Crear módulos reales para clientes, facturación y devoluciones.

## Recomendación

1. Mantener la app local-first por ahora.
2. Validar compilación y comportamiento del inventario.
3. Luego crear la cuenta y proyecto de Supabase.
4. Conectar primero inventario, después facturación y devoluciones.

## Nota sobre el entorno

- Los comandos `flutter test` y `dart analyze` se quedaron colgados en esta sesión.
- Por eso la validación automática quedó pendiente, aunque el refactor sí fue aplicado.

