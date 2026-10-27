-- Consultas de ejemplo para reportes
SET search_path TO facturacion;

-- Ventas por mes
SELECT * FROM v_ventas_mensuales ORDER BY mes;

-- Ranking de clientes
SELECT * FROM v_top_clientes ORDER BY posicion;

-- Productos más vendidos por valor
SELECT * FROM v_productos_mas_vendidos ORDER BY ventas DESC;

-- Resumen de IVA por tarifa (útil para la declaración bimestral)
SELECT d.iva_pct AS tarifa, SUM(d.subtotal) AS base, SUM(d.valor_iva) AS iva
  FROM factura_detalle d JOIN facturas f ON f.id = d.factura_id
 WHERE f.estado = 'EMITIDA'
 GROUP BY d.iva_pct ORDER BY d.iva_pct;

-- Ventas acumuladas por cliente con función de ventana
SELECT c.razon_social, f.numero, f.fecha, f.total,
       SUM(f.total) OVER (PARTITION BY c.id ORDER BY f.fecha) AS acumulado
  FROM facturas f JOIN clientes c ON c.id = f.cliente_id
 WHERE f.estado = 'EMITIDA'
 ORDER BY c.razon_social, f.fecha;
