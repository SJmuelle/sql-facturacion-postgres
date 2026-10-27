-- Pruebas automáticas: cada bloque falla con EXCEPTION si algo no cuadra.
SET search_path TO facturacion;
\set ON_ERROR_STOP on

DO $$
BEGIN
    -- Factura 1: 40 x 120.000 + 350.000 = 5.150.000; IVA 19% = 978.500
    ASSERT (SELECT subtotal FROM facturas WHERE id = 1) = 5150000, 'subtotal factura 1';
    ASSERT (SELECT total_iva FROM facturas WHERE id = 1) = 978500, 'IVA factura 1';
    ASSERT (SELECT total FROM facturas WHERE id = 1) = 6128500, 'total factura 1';
    -- Factura 2: 800.000 (0%) + 320.000 (5% = 16.000)
    ASSERT (SELECT total FROM facturas WHERE id = 2) = 1136000, 'total factura 2';
    ASSERT (SELECT numero FROM facturas WHERE id = 1) = 'FE-1000', 'consecutivo';
    RAISE NOTICE 'OK totales y consecutivo';
END $$;

DO $$
BEGIN
    BEGIN
        INSERT INTO factura_detalle (factura_id, producto_id, cantidad) VALUES (1, 1, 1);
        RAISE EXCEPTION 'debió fallar: factura emitida modificable';
    EXCEPTION WHEN raise_exception THEN
        IF SQLERRM LIKE 'debió fallar%' THEN RAISE; END IF;
    END;
    RAISE NOTICE 'OK factura emitida es inmutable';
END $$;

DO $$
BEGIN
    BEGIN
        INSERT INTO facturas (cliente_id) VALUES (3);
        CALL sp_emitir_factura(currval('facturas_id_seq')::int);
        RAISE EXCEPTION 'debió fallar: factura sin ítems emitida';
    EXCEPTION WHEN raise_exception THEN
        IF SQLERRM LIKE 'debió fallar%' THEN RAISE; END IF;
    END;
    RAISE NOTICE 'OK no se emiten facturas vacías';
END $$;

DO $$
BEGIN
    DELETE FROM factura_detalle WHERE factura_id = 3;
    ASSERT (SELECT total FROM facturas WHERE id = 3) = 0, 'recalculo al borrar';
    ASSERT (SELECT COUNT(*) FROM v_top_clientes) = 2, 'vista top clientes';
    ASSERT (SELECT posicion FROM v_top_clientes WHERE id = 1) = 1, 'ranking';
    RAISE NOTICE 'OK recálculo y vistas';
END $$;
