# Sincronización Bidireccional Real — Plan de Implementación

Con los permisos SQL ya aplicados en Supabase, estos son los tres problemas pendientes que debemos resolver en el código de la app.

---

## Resumen del problema actual

```
[App] → guarda en Isar (isSynced=false) → encola en SyncService
[SyncService] → hace upsert a Supabase ✅ (ahora con permisos)
[Bug 1] → NO actualiza isSynced=true en Isar → UI queda en "Pendiente" para siempre
[Bug 2] → NO encola los detalles de factura → Supabase recibe facturas sin productos
[Bug 3] → pullAll() hace SELECT pero descarta la respuesta → sincronización de bajada no funciona
```

---

## Cambio 1 — `SyncService`: Actualizar `isSynced=true` en Isar tras push exitoso

> [!IMPORTANT]
> Este es el bug principal. Sin esto, el badge siempre dice "Pendiente" aunque los datos ya estén en Supabase.

### ¿Qué cambia?

**Archivo:** [sync_service.dart](file:///c:/Users/crisn/.gemini/antigravity/scratch/super_motos/lib/core/services/sync_service.dart)

Actualmente `_pushItem()` llama a `item.markSynced()` sobre el item de cola local, pero nunca va a Isar a poner `isSynced = true` en el modelo real. La solución es añadir un método `markLocalSynced(table, recordId)` que abra una transacción Isar y actualice la bandera según la tabla.

**Lógica a añadir en `_pushItem` después del upsert exitoso:**
```dart
// Después de _upsertRecord(client, item):
await _markLocalSynced(item);
```

**Nuevo método `_markLocalSynced`** (switch por tabla, igual que `_upsertRecord`):
- `clientes` → `isar.clienteModels.get(id)` → `model.isSynced = true` → `isar.clienteModels.put(model)`
- `facturas` → igual con `facturaModels`
- `devoluciones` → igual con `devolucionModels`
- `proveedores` → igual con `proveedorModels`
- `historial_precios` → igual con `historialPreciosModels`
- `productos` → igual con `productoModels`
- `inventario_camion` → igual con `inventarioCamionModels`
- `inventario_bodega` → igual con `inventarioBodegaModels`

> [!NOTE]
> Para que `SyncService` pueda tocar Isar necesita importar los modelos correspondientes. Usamos `Isar.getInstance()` (el mismo patrón de los repositorios) para no acoplar una instancia fija.

---

## Cambio 2 — `IsarFacturasRepository`: Encolar `detalles_factura`

> [!IMPORTANT]
> Sin esto, Supabase recibe la factura principal pero la tabla `detalles_factura` queda vacía. Las facturas se ven incompletas en la nube.

### ¿Qué cambia?

**Archivo:** [facturas_repository_io.dart](file:///c:/Users/crisn/.gemini/antigravity/scratch/super_motos/lib/features/billing/data/repositories/facturas_repository_io.dart)

En el método `create()`, después de encolar la factura, iterar cada `DetalleFacturaModel` y encolarlo por separado:

```dart
// Después de encolar la factura principal:
if (saved.detalles != null) {
  for (final detalle in saved.detalles!) {
    final detalleJson = jsonEncode({
      'factura_numero': saved.numeroFactura,
      'producto_id': detalle.productoId,
      'cantidad': detalle.cantidad,
      'precio_unitario': detalle.precioUnitario,
      'subtotal': detalle.subtotal,
      'updated_at': DateTime.now().toIso8601String(),
    });
    SyncService.instance.enqueue('detalles_factura', SyncOperation.insert, detalleJson);
  }
}
```

> [!NOTE]
> `DetalleFacturaModel` es un `@embedded` en Isar (sin ID propio), por lo que no se puede actualizar `isSynced` individualmente. Se deja el `isSynced` del padre `FacturaModel` como indicador unificado.

---

## Cambio 3 — `SyncService.pullAll()`: Persistir datos descargados en Isar

> [!IMPORTANT]
> Actualmente el pull trae datos de Supabase y los tira a la basura. Sin esto, si dos vendedores comparten el mismo Supabase, los cambios del otro nunca aparecen.

### ¿Qué cambia?

**Archivo:** [sync_service.dart](file:///c:/Users/crisn/.gemini/antigravity/scratch/super_motos/lib/core/services/sync_service.dart)

Refactorizar `_pullTable()` para que, en lugar de descartar la respuesta, la deserialice y la guarde en Isar usando `writeTxn`:

```dart
// Por tabla, ejemplo clientes:
case 'clientes':
  for (final row in response) {
    final model = ClienteModel()
      ..id = row['id'] as int
      ..nombre = row['nombre'] as String
      // ... demás campos
      ..isSynced = true;
    await isar.clienteModels.put(model);
  }
```

**Tablas a cubrir en `pullAll()`:**
| Tabla Supabase | Modelo Isar | Condición |
|---|---|---|
| `clientes` | `ClienteModel` | Siempre |
| `productos` | `ProductoModel` | Siempre |
| `inventario_camion` | `InventarioCamionModel` | Siempre |
| `inventario_bodega` | `InventarioBodegaModel` | Siempre |
| `facturas` | `FacturaModel` | Siempre |
| `devoluciones` | `DevolucionModel` | Siempre |
| `proveedores` | `ProveedorModel` | Siempre |
| `historial_precios` | `HistorialPreciosModel` | Siempre |

> [!NOTE]
> Los registros descargados de la nube se guardan con `isSynced = true` porque ya existen en Supabase. Así la UI los muestra como "Sincronizado" de inmediato.

---

## Orden de ejecución

| # | Cambio | Impacto |
|---|---|---|
| 1 | `SyncService._markLocalSynced()` | Badges pasan a ✅ en UI |
| 2 | `detalles_factura` enqueue | Facturas completas en Supabase |
| 3 | `pullAll()` persistente | Descarga datos desde la nube |

---

## Verificación

### Automática
```bash
flutter test test/features/billing/facturas_test.dart
flutter test test/features/customers/clientes_test.dart
flutter analyze
```

### Manual en emulador
1. Crear un cliente → esperar ≤ 10s → el badge debe cambiar a ✅ "Sincronizado"
2. Ir al panel de Supabase → SQL Editor → `SELECT * FROM clientes;` → verificar que el registro aparece
3. Crear una factura con 2 productos → verificar en `SELECT * FROM detalles_factura;` que aparecen 2 filas
4. Instalar la app en un segundo dispositivo → al abrir, debe recibir los datos del primero vía `pullAll()`

---

## Archivos a modificar

| Archivo | Tipo de cambio |
|---|---|
| [sync_service.dart](file:///c:/Users/crisn/.gemini/antigravity/scratch/super_motos/lib/core/services/sync_service.dart) | Cambio 1 + Cambio 3 |
| [facturas_repository_io.dart](file:///c:/Users/crisn/.gemini/antigravity/scratch/super_motos/lib/features/billing/data/repositories/facturas_repository_io.dart) | Cambio 2 |

Solo **2 archivos** modificados. No se tocan modelos ni se regenera código Isar.
