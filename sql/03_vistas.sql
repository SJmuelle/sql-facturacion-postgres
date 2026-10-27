SET search_path TO facturacion;

CREATE OR REPLACE VIEW v_ventas_mensuales AS
SELECT date_trunc('month', fecha)::date AS mes,
       COUNT(*)                         AS facturas,
       SUM(subtotal)                    AS subtotal,
       SUM(total_iva)                   AS iva,
       SUM(total)                       AS total
  FROM facturas
 WHERE estado = 'EMITIDA'
 GROUP BY 1;

CREATE OR REPLACE VIEW v_top_clientes AS
SELECT c.id, c.razon_social, COUNT(f.id) AS facturas, SUM(f.total) AS total_comprado,
       RANK() OVER (ORDER BY SUM(f.total) DESC) AS posicion
  FROM clientes c
  JOIN facturas f ON f.cliente_id = c.id AND f.estado = 'EMITIDA'
 GROUP BY c.id, c.razon_social;

CREATE OR REPLACE VIEW v_productos_mas_vendidos AS
SELECT p.codigo, p.nombre, SUM(d.cantidad) AS unidades, SUM(d.subtotal) AS ventas
  FROM factura_detalle d
  JOIN facturas f  ON f.id = d.factura_id AND f.estado = 'EMITIDA'
  JOIN productos p ON p.id = d.producto_id
 GROUP BY p.codigo, p.nombre;
