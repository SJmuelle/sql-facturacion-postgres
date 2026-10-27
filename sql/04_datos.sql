SET search_path TO facturacion;

INSERT INTO clientes (tipo_documento, numero_documento, razon_social, email, ciudad) VALUES
 ('NIT', '900123456', 'Comercializadora del Caribe SAS', 'compras@caribe.co', 'Barranquilla'),
 ('NIT', '901987654', 'Ferretería La Costa Ltda',       'pagos@lacosta.co',  'Santa Marta'),
 ('CC',  '1045678901', 'María Fernanda Ortiz',          'mfortiz@mail.com',  'Soledad');

INSERT INTO productos (codigo, nombre, precio, iva_pct) VALUES
 ('SRV-DEV',  'Hora de desarrollo de software', 120000, 19),
 ('LIC-ERP',  'Licencia mensual ERP',           350000, 19),
 ('CAP-001',  'Capacitación presencial',        800000, 0),
 ('ALM-ARR',  'Arroz 500 g',                      3200, 5);

-- Factura 1
INSERT INTO facturas (cliente_id, fecha) VALUES (1, DATE '2026-09-15');
INSERT INTO factura_detalle (factura_id, producto_id, cantidad) VALUES (1, 1, 40), (1, 2, 1);
CALL sp_emitir_factura(1);

-- Factura 2
INSERT INTO facturas (cliente_id, fecha) VALUES (2, DATE '2026-10-02');
INSERT INTO factura_detalle (factura_id, producto_id, cantidad) VALUES (2, 3, 1), (2, 4, 100);
CALL sp_emitir_factura(2);

-- Factura 3 (queda en borrador)
INSERT INTO facturas (cliente_id, fecha) VALUES (3, DATE '2026-10-20');
INSERT INTO factura_detalle (factura_id, producto_id, cantidad) VALUES (3, 1, 5);
