-- =============================================================
-- Modelo de facturación electrónica simplificado (PostgreSQL 16)
-- =============================================================
DROP SCHEMA IF EXISTS facturacion CASCADE;
CREATE SCHEMA facturacion;
SET search_path TO facturacion;

CREATE TYPE tipo_documento AS ENUM ('CC', 'NIT', 'CE');
CREATE TYPE estado_factura AS ENUM ('BORRADOR', 'EMITIDA', 'ANULADA');

CREATE TABLE clientes (
    id              SERIAL PRIMARY KEY,
    tipo_documento  tipo_documento NOT NULL,
    numero_documento VARCHAR(20)   NOT NULL,
    razon_social    VARCHAR(150)   NOT NULL,
    email           VARCHAR(120)   CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    ciudad          VARCHAR(80)    NOT NULL DEFAULT 'Barranquilla',
    creado_en       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    UNIQUE (tipo_documento, numero_documento)
);

CREATE TABLE productos (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(30)    NOT NULL UNIQUE,
    nombre      VARCHAR(120)   NOT NULL,
    precio      NUMERIC(14, 2) NOT NULL CHECK (precio >= 0),
    iva_pct     NUMERIC(5, 2)  NOT NULL DEFAULT 19 CHECK (iva_pct IN (0, 5, 19)),
    activo      BOOLEAN        NOT NULL DEFAULT TRUE
);

CREATE SEQUENCE consecutivo_factura START 1000;

CREATE TABLE facturas (
    id          SERIAL PRIMARY KEY,
    numero      VARCHAR(20)    NOT NULL UNIQUE DEFAULT 'FE-' || nextval('consecutivo_factura'),
    cliente_id  INT            NOT NULL REFERENCES clientes (id),
    fecha       DATE           NOT NULL DEFAULT CURRENT_DATE,
    estado      estado_factura NOT NULL DEFAULT 'BORRADOR',
    subtotal    NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total_iva   NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total       NUMERIC(14, 2) GENERATED ALWAYS AS (subtotal + total_iva) STORED
);

CREATE TABLE factura_detalle (
    id           SERIAL PRIMARY KEY,
    factura_id   INT            NOT NULL REFERENCES facturas (id) ON DELETE CASCADE,
    producto_id  INT            NOT NULL REFERENCES productos (id),
    cantidad     INT            NOT NULL CHECK (cantidad > 0),
    precio_unit  NUMERIC(14, 2) NOT NULL,
    iva_pct      NUMERIC(5, 2)  NOT NULL,
    subtotal     NUMERIC(14, 2) GENERATED ALWAYS AS (cantidad * precio_unit) STORED,
    valor_iva    NUMERIC(14, 2) GENERATED ALWAYS AS (ROUND(cantidad * precio_unit * iva_pct / 100, 2)) STORED
);

CREATE INDEX idx_facturas_cliente ON facturas (cliente_id);
CREATE INDEX idx_facturas_fecha ON facturas (fecha);
CREATE INDEX idx_detalle_factura ON factura_detalle (factura_id);
