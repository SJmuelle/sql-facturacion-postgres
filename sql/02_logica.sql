SET search_path TO facturacion;

-- Toma precio e IVA vigentes del producto y bloquea cambios en facturas no borrador
CREATE OR REPLACE FUNCTION fn_preparar_detalle() RETURNS TRIGGER AS $$
DECLARE
    v_estado estado_factura;
BEGIN
    SELECT estado INTO v_estado FROM facturas
     WHERE id = COALESCE(NEW.factura_id, OLD.factura_id);
    IF v_estado <> 'BORRADOR' THEN
        RAISE EXCEPTION 'La factura % no está en borrador y no puede modificarse',
            COALESCE(NEW.factura_id, OLD.factura_id);
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    SELECT precio, iva_pct INTO NEW.precio_unit, NEW.iva_pct
      FROM productos WHERE id = NEW.producto_id AND activo;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto % inexistente o inactivo', NEW.producto_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_preparar_detalle
BEFORE INSERT OR UPDATE OR DELETE ON factura_detalle
FOR EACH ROW EXECUTE FUNCTION fn_preparar_detalle();

-- Recalcula totales de la factura cuando cambia el detalle
CREATE OR REPLACE FUNCTION fn_recalcular_totales() RETURNS TRIGGER AS $$
DECLARE
    v_factura INT := COALESCE(NEW.factura_id, OLD.factura_id);
BEGIN
    UPDATE facturas f
       SET subtotal  = COALESCE(d.sub, 0),
           total_iva = COALESCE(d.iva, 0)
      FROM (SELECT SUM(subtotal) sub, SUM(valor_iva) iva
              FROM factura_detalle WHERE factura_id = v_factura) d
     WHERE f.id = v_factura;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalcular_totales
AFTER INSERT OR UPDATE OR DELETE ON factura_detalle
FOR EACH ROW EXECUTE FUNCTION fn_recalcular_totales();

-- Procedimiento para emitir una factura (debe tener al menos un ítem)
CREATE OR REPLACE PROCEDURE sp_emitir_factura(p_factura_id INT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM factura_detalle WHERE factura_id = p_factura_id) THEN
        RAISE EXCEPTION 'La factura % no tiene ítems', p_factura_id;
    END IF;
    UPDATE facturas SET estado = 'EMITIDA'
     WHERE id = p_factura_id AND estado = 'BORRADOR';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura % no existe o no está en borrador', p_factura_id;
    END IF;
END;
$$ LANGUAGE plpgsql;
