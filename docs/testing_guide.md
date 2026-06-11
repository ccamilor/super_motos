# Guía de Pruebas — MotoRuta Pro

> Documentación completa de casos de prueba para todos los módulos de la app.
> Creado: 2026-06-11

---

## 1. Funcionamiento Offline

**La app funciona 100% sin internet.** La arquitectura es `local-first`:

```
┌─────────────────────────────────────────────┐
│  TU CELULAR (Android)                       │
│                                             │
│  ┌──────────────────┐   ┌────────────────┐ │
│  │  Isar (local DB) │ ←→ │  App Flutter   │ │
│  │  Sin conexión    │   │  Funcionando   │ │
│  └──────────────────┘   └────────────────┘ │
│         ↓↑ sync (cuando hay internet)       │
│  ┌──────────────────┐                       │
│  │  Supabase (cloud)│  ← Solo para sync     │
│  └──────────────────┘                       │
└─────────────────────────────────────────────┘
```

| Funcionalidad | ¿Funciona sin internet? |
|---|---|
| Ver inventario | ✅ Sí — Isar local |
| Crear/editar productos | ✅ Sí — Isar local |
| Crear facturas | ✅ Sí — Isar local |
| Ver clientes | ✅ Sí — Isar local |
| Devoluciones | ✅ Sí — Isar local |
| Proveedores | ✅ Sí — Isar local |
| **Sync con Supabase** | ❌ Solo cuando hay conexión |

---

## 2. Módulo: Inventario

### Prueba: Carga y navegación

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Abrir la app e ir a "Inventario Total" | Ver los productos cargados |
| 2 | Tocar el FAB "Nuevo Producto" | Se abre el formulario de producto |
| 3 | Llenar: nombre, precio, tipo (ORIGINAL/GENÉRICO), stock mínimo | Formulario acepta todos los campos |
| 4 | Guardar | Producto aparece en la lista |
| 5 | Tocar "CSV" en el AppBar | Se abre el selector de archivos |
| 6 | Importar un CSV | Productos se actualizan, snackbar de éxito |

### Prueba: Scroll y colapso

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Hacer scroll hacia abajo | El search y TabBar colapzan hacia arriba |
| 2 | Hacer scroll hacia arriba | TabBar reaparece fija arriba, search vuelve |
| 3 | Girar el celular (horizontal) | La UI se adapta correctamente |

### Prueba: Tarjetas y badges

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | En "Mi Camión": producto con stock bajo | Muestra "STOCK BAJO" en rojo |
| 2 | En "Inventario Total": producto con stock bajo en camión | Muestra "STOCK BAJO" en rojo |
| 3 | En "Inventario Total": producto original | Badge "ORIGINAL" completo |
| 4 | En "Inventario Total": producto genérico | Badge "GENÉRICO" completo |
| 5 | En "Bodega Central": producto | Muestra "ALMACÉN CENTRAL" |

### Prueba: Buscar

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Escribir en el campo de búsqueda | La lista se filtra instantáneamente |
| 2 | Tocar la X para limpiar | Todos los productos vuelven a aparecer |
| 3 | Dejar vacío | Se muestran todos los productos |

---

## 3. Módulo: Facturas (Facturación)

### Prueba: Crear factura

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ir a la pantalla de Facturas | Lista de facturas ordenadas por fecha |
| 2 | Tocar el botón "+" para crear factura | Se abre el formulario |
| 3 | Seleccionar cliente | Cliente asignado a la factura |
| 4 | Agregar productos (seleccionar cantidad) | Productos aparecen como líneas |
| 5 | Verificar que al facturar se descuenta stock del camión | Stock en "Mi Camión" disminuye |
| 6 | Guardar factura | Aparece en la lista con número de factura |

### Prueba: Detalle y navegación

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Tocar una factura existente | Se abre el detalle |
| 2 | En detalle: ver coordenadas GPS (si están disponibles) | Se muestra lat/lon al final |
| 3 | Tocar flecha de regreso | Vuelve a la lista de facturas |
| 4 | Cambiar orientación del celular | La vista se adapta correctamente |

### Prueba: Stock insuficiente

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Intentar crear factura con producto sin stock | Mensaje de error o alerta |
| 2 | Factura con stock 0 | App maneja el caso sin crash |

---

## 4. Módulo: Clientes

### Prueba: CRUD

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ir a Clientes | Lista de clientes ordenados alfabéticamente |
| 2 | Crear nuevo cliente | Se guarda y aparece en la lista |
| 3 | Editar un cliente existente | Cambios se guardan |
| 4 | Eliminar un cliente | Se pide confirmación, luego se elimina |

### Prueba: Buscar y filtrar

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Buscar un cliente por nombre | La lista se filtra instantáneamente |
| 2 | Dejar vacío | Se muestran todos los clientes |

### Prueba: Detalle

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ver detalle de un cliente | Muestra todos los datos |
| 2 | Ver historial de compras | Se muestra si existe |

---

## 5. Módulo: Devoluciones

### Prueba: Crear devolución

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ir a Devoluciones | Lista de devoluciones |
| 2 | Crear nueva devolución | Seleccionar factura + productos a devolver |
| 3 | Confirmar devolución | Se incrementa el stock en "Mi Camión" |

### Prueba: Eliminar devolución

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Eliminar una devolución | Stock vuelve a bajar |
| 2 | Confirmar eliminación | La devolución desaparece de la lista |

---

## 6. Módulo: Proveedores

### Prueba: CRUD

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ir a Proveedores | Lista de proveedores |
| 2 | Crear proveedor con historial de precios | Se guarda correctamente |
| 3 | Editar proveedor | Cambios se persisten |
| 4 | Eliminar proveedor | Se pide confirmación y se elimina |

### Prueba: Historial de precios

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Ver historial de precios de un producto | Muestra la tabla de precios por proveedor |
| 2 | Agregar nuevo precio a un proveedor | Se guarda en el historial |
| 3 | Ver producto en Inventario Total | Muestra precio actual |

---

## 7. Módulo: Sync con Supabase

### Prueba: Sincronización

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Con WiFi/datos móviles: abrir la app | El sync indicator muestra estado |
| 2 | Crear un producto con el celular A (sin conexión) | Se guarda localmente |
| 3 | Conectar el celular A a internet | Los datos se suben a Supabase automáticamente |
| 4 | En celular B: abrir la app con internet | Los productos nuevos aparecen |
| 5 | Simular conflicto (mismo producto editado en ambos) | Se aplica "last write wins" |

### Prueba: Cola offline

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Crear varios registros sin internet | Se guardan en la cola local |
| 2 | Conectar a internet | La cola se procesa en orden |
| 3 | Ver indicador de pendientes | Muestra el conteo correctamente |

---

## 8. Módulo: Login y Roles

### Prueba: Login

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Abrir app sin haber logueado | Pantalla de Login |
| 2 | Login como Mayra (admin) | Acceso completo a todas las pantallas |
| 3 | Login como Mateo (vendedor) | Acceso a inventario, facturas, clientes, devoluciones |
| 4 | Logout | Vuelve a pantalla de Login |

### Prueba: Login rápido

| Paso | Acción | Resultado esperado |
|---|---|---|
| 1 | Tocar tarjeta "Mayra" en login rápido | Entra directo sin pedir password |
| 2 | Tocar tarjeta "Mateo" | Entra directo sin pedir password |
| 3 | Login con email/password | Valida contra Supabase |

---

## 9. Casos Extremos

| Escenario | Qué hacer | Esperado |
|---|---|---|
| **Sin internet** | Desactivar WiFi y datos, abrir la app | App funciona normalmente con datos locales |
| **Stock en 0** | Intentar crear factura con producto sin stock | Mensaje de error o alerta de stock insuficiente |
| **Buscar con texto vacío** | Dejar el campo de búsqueda vacío | Se muestran todos los productos |
| **Many products** | Importar CSV con 100+ productos | El scroll se mantiene fluido |
| **Rotación horizontal** | Girar el celular durante uso | La UI se adapta sin crash |
| **Navegación profunda** | Ir a Inventario → Factura → Detalle → Volver | La flecha de regreso funciona correctamente |
| **Reinstalar app** | Desinstalar y reinstallar | Los datos se pierden (Isar se borra con la app) |
| **CSV malformado** | Importar archivo con formato incorrecto | Mensaje de error claro |
| **Producto duplicado** | Importar CSV con producto ya existente | Se actualiza o se crea duplicado según lógica |

---

## 10. Verificar DB local

| Paso | Acción | Indicador |
|---|---|---|
| 1 | Crear 5 productos nuevos | Todos aparecen en la lista |
| 2 | Cerrar la app completamente | — |
| 3 | Volver a abrir la app | Los 5 productos siguen ahí |
| 4 | Desinstalar y reinstallar la app | Los datos se pierden (Isar se borra con la app) |

> **Nota:** Si necesitas que los datos sobrevivan a una reinstalación, necesitas tener el sync con Supabase activo y conectado.

---

## 11. Qué NO funciona sin internet

| Funcionalidad | ¿Por qué? |
|---|---|
| Login con Supabase Auth (usuarios nuevos) | Auth requiere conexión a Supabase |
| Ver productos de otros vendedores (si hay multiusuario) | No hay sync en tiempo real |
| Descargar datos de un servidor central | Sin conexión no hay descarga |
| Sync con Supabase | Solo disponible con conexión a internet |

---

## 12. Checklist antes de decir "app completa"

- [ ] Puedo crear, editar y eliminar productos
- [ ] El search filtra correctamente en los 3 tabs
- [ ] El TabBar queda fijo arriba al hacer scroll
- [ ] El search colapza y reaparece con el scroll
- [ ] Las tarjetas muestran badge completo (ORIGINAL/GENÉRICO)
- [ ] STOCK BAJO aparece en rojo cuando corresponde
- [ ] El FAB "Nuevo Producto" aparece solo en Inventario Total
- [ ] La flecha de regreso funciona correctamente
- [ ] No hay iconos duplicados o superpuestos
- [ ] Puedo crear facturas y se descuenta stock
- [ ] Puedo hacer devoluciones y se incrementa stock
- [ ] El sync funciona cuando hay conexión
- [ ] La app funciona offline completamente
- [ ] Los tests pasan (35 tests)