-- ============================================================================
-- MotoRuta Pro — Schema completo para Supabase (IDs String alfanumericos)
-- ============================================================================
-- Instrucciones:
--   1. Crea un proyecto nuevo en https://supabase.com
--   2. Ve a SQL Editor en el panel izquierdo
--   3. Pega este archivo entero y ejecutalo (boton "Run" o Ctrl+Enter)
--   4. Crea los usuarios desde Authentication > Users
--   5. Listo. Tu backend ya tiene tablas y permisos.
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONES
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- ============================================================================
-- 2. FUNCION DE TRIGGER: actualiza updated_at automaticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. TABLAS
-- ============================================================================

-- 3.1 Productos (catalogo de repuestos)
CREATE TABLE IF NOT EXISTS productos (
    codigo              TEXT PRIMARY KEY,
    nombre              TEXT NOT NULL,
    precio              DOUBLE PRECISION NOT NULL DEFAULT 0,
    imagen_url          TEXT,
    is_original         BOOLEAN NOT NULL DEFAULT FALSE,
    motos_compatibles   TEXT NOT NULL DEFAULT '',
    stock_minimo        INTEGER NOT NULL DEFAULT 0,
    is_synced           BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_productos_updated_at
    BEFORE UPDATE ON productos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.2 Inventario Camion (stock que lleva el vendedor en ruta)
CREATE TABLE IF NOT EXISTS inventario_camion (
    codigo          TEXT PRIMARY KEY,
    producto_id     TEXT NOT NULL REFERENCES productos(codigo) ON DELETE CASCADE,
    canasta_id      TEXT NOT NULL DEFAULT '',
    cantidad        INTEGER NOT NULL DEFAULT 0,
    is_synced       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_inventario_camion_updated_at
    BEFORE UPDATE ON inventario_camion
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.3 Inventario Bodega (stock en bodega central)
CREATE TABLE IF NOT EXISTS inventario_bodega (
    codigo          TEXT PRIMARY KEY,
    producto_id     TEXT NOT NULL REFERENCES productos(codigo) ON DELETE CASCADE,
    cantidad        INTEGER NOT NULL DEFAULT 0,
    is_synced       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_inventario_bodega_updated_at
    BEFORE UPDATE ON inventario_bodega
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.4 Clientes
CREATE TABLE IF NOT EXISTS clientes (
    codigo                  TEXT PRIMARY KEY,
    nombre                  TEXT NOT NULL,
    identificador_fiscal    TEXT NOT NULL DEFAULT '',
    direccion               TEXT NOT NULL DEFAULT '',
    latitud                 DOUBLE PRECISION,
    longitud                DOUBLE PRECISION,
    limite_credito          DOUBLE PRECISION NOT NULL DEFAULT 0,
    saldo_pendiente         DOUBLE PRECISION NOT NULL DEFAULT 0,
    estado_cuenta           TEXT NOT NULL DEFAULT 'activo'
                            CHECK (estado_cuenta IN ('activo', 'suspendido', 'sinCredito')),
    is_synced               BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_clientes_updated_at
    BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.5 Facturas (ventas en ruta)
CREATE TABLE IF NOT EXISTS facturas (
    codigo          TEXT PRIMARY KEY,
    cliente_id      TEXT NOT NULL REFERENCES clientes(codigo),
    vendedor_id     TEXT NOT NULL DEFAULT '',
    fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total           DOUBLE PRECISION NOT NULL DEFAULT 0,
    tipo_pago       TEXT NOT NULL DEFAULT 'contado'
                    CHECK (tipo_pago IN ('contado', 'credito', 'transferencia')),
    latitud_venta   DOUBLE PRECISION,
    longitud_venta  DOUBLE PRECISION,
    is_synced       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_facturas_updated_at
    BEFORE UPDATE ON facturas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.6 Detalles de Factura (lineas de cada venta)
CREATE TABLE IF NOT EXISTS detalles_factura (
    codigo          TEXT PRIMARY KEY,
    factura_codigo  TEXT NOT NULL REFERENCES facturas(codigo) ON DELETE CASCADE,
    producto_id     TEXT REFERENCES productos(codigo),
    cantidad        INTEGER DEFAULT 0,
    precio_unitario DOUBLE PRECISION DEFAULT 0,
    subtotal        DOUBLE PRECISION DEFAULT 0,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_detalles_factura_updated_at
    BEFORE UPDATE ON detalles_factura
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.7 Devoluciones (productos devueltos por el cliente)
CREATE TABLE IF NOT EXISTS devoluciones (
    codigo              TEXT PRIMARY KEY,
    factura_id          TEXT NOT NULL DEFAULT '',
    producto_id         TEXT NOT NULL DEFAULT '',
    cantidad            INTEGER NOT NULL DEFAULT 0,
    canasta_destino     TEXT NOT NULL DEFAULT '',
    fecha_devolucion    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    motivo              TEXT NOT NULL DEFAULT '',
    is_synced           BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_devoluciones_updated_at
    BEFORE UPDATE ON devoluciones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.8 Proveedores
CREATE TABLE IF NOT EXISTS proveedores (
    codigo      TEXT PRIMARY KEY,
    nombre      TEXT NOT NULL,
    nit         TEXT NOT NULL DEFAULT '',
    telefono    TEXT NOT NULL DEFAULT '',
    direccion   TEXT NOT NULL DEFAULT '',
    is_synced   BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_proveedores_updated_at
    BEFORE UPDATE ON proveedores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3.9 Historial de Precios (precios de compra por producto/proveedor)
CREATE TABLE IF NOT EXISTS historial_precios (
    codigo          TEXT PRIMARY KEY,
    producto_id     TEXT NOT NULL DEFAULT '',
    proveedor_id    TEXT NOT NULL DEFAULT '',
    precio_compra   DOUBLE PRECISION NOT NULL DEFAULT 0,
    fecha_registro  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_synced       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_historial_precios_updated_at
    BEFORE UPDATE ON historial_precios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. INDICES (para busquedas frecuentes)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_inventario_camion_producto ON inventario_camion(producto_id);
CREATE INDEX IF NOT EXISTS idx_inventario_camion_canasta ON inventario_camion(canasta_id);
CREATE INDEX IF NOT EXISTS idx_inventario_bodega_producto ON inventario_bodega(producto_id);
CREATE INDEX IF NOT EXISTS idx_clientes_identificador ON clientes(identificador_fiscal);
CREATE INDEX IF NOT EXISTS idx_clientes_nombre ON clientes(nombre);
CREATE INDEX IF NOT EXISTS idx_facturas_cliente ON facturas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_detalles_factura_factura ON detalles_factura(factura_codigo);
CREATE INDEX IF NOT EXISTS idx_detalles_factura_producto ON detalles_factura(producto_id);
CREATE INDEX IF NOT EXISTS idx_devoluciones_factura ON devoluciones(factura_id);
CREATE INDEX IF NOT EXISTS idx_proveedores_nit ON proveedores(nit);
CREATE INDEX IF NOT EXISTS idx_historial_precios_producto ON historial_precios(producto_id);
CREATE INDEX IF NOT EXISTS idx_historial_precios_proveedor ON historial_precios(proveedor_id);

-- ============================================================================
-- 5. RLS — POLITICAS DE SEGURIDAD (modo desarrollo: todo abierto)
-- ============================================================================

ALTER TABLE productos           ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario_camion   ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario_bodega   ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE facturas            ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalles_factura    ENABLE ROW LEVEL SECURITY;
ALTER TABLE devoluciones        ENABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores         ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_precios   ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for anon"
    ON productos FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON inventario_camion FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON inventario_bodega FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON clientes FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON facturas FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON detalles_factura FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON devoluciones FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON proveedores FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon"
    ON historial_precios FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for authenticated"
    ON productos FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON inventario_camion FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON inventario_bodega FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON clientes FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON facturas FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON detalles_factura FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON devoluciones FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON proveedores FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated"
    ON historial_precios FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
