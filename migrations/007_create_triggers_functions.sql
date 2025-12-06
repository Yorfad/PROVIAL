-- Migración 007: Triggers y funciones

-- ========================================
-- FUNCIÓN: Actualizar updated_at automáticamente
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column IS 'Actualiza automáticamente la columna updated_at al modificar un registro';

-- Aplicar trigger a tablas con updated_at
CREATE TRIGGER update_usuario_updated_at
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_unidad_updated_at
    BEFORE UPDATE ON unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incidente_updated_at
    BEFORE UPDATE ON incidente
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_actividad_updated_at
    BEFORE UPDATE ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_obstruccion_updated_at
    BEFORE UPDATE ON obstruccion_incidente
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- FUNCIÓN: Generar número de reporte automático
-- ========================================

CREATE OR REPLACE FUNCTION generar_numero_reporte()
RETURNS TRIGGER AS $$
DECLARE
    anio INT;
    secuencia INT;
BEGIN
    -- Obtener año del aviso
    anio := EXTRACT(YEAR FROM NEW.fecha_hora_aviso);

    -- Obtener siguiente número secuencial del año
    SELECT COALESCE(
        MAX(
            CAST(
                SUBSTRING(numero_reporte FROM 'INC-\d{4}-(\d+)') AS INT
            )
        ), 0
    ) + 1
    INTO secuencia
    FROM incidente
    WHERE EXTRACT(YEAR FROM fecha_hora_aviso) = anio;

    -- Generar número: INC-2025-0001
    NEW.numero_reporte := 'INC-' || anio || '-' || LPAD(secuencia::TEXT, 4, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_numero_reporte IS 'Genera automáticamente el número de reporte en formato INC-YYYY-####';

CREATE TRIGGER trigger_generar_numero_reporte
    BEFORE INSERT ON incidente
    FOR EACH ROW
    WHEN (NEW.numero_reporte IS NULL)
    EXECUTE FUNCTION generar_numero_reporte();

-- ========================================
-- FUNCIÓN: Cerrar actividad anterior al abrir nueva
-- ========================================

CREATE OR REPLACE FUNCTION cerrar_actividad_anterior()
RETURNS TRIGGER AS $$
BEGIN
    -- Cerrar cualquier actividad previa abierta de la misma unidad
    UPDATE actividad_unidad
    SET hora_fin = NEW.hora_inicio
    WHERE unidad_id = NEW.unidad_id
      AND hora_fin IS NULL
      AND id != COALESCE(NEW.id, 0);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_actividad_anterior IS 'Cierra automáticamente la actividad anterior al iniciar una nueva para la misma unidad';

CREATE TRIGGER trigger_cerrar_actividad_anterior
    BEFORE INSERT ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION cerrar_actividad_anterior();

-- ========================================
-- FUNCIÓN: Validar que actividad con incidente tenga tipo correcto
-- ========================================

CREATE OR REPLACE FUNCTION validar_actividad_incidente()
RETURNS TRIGGER AS $$
DECLARE
    requiere_incidente_val BOOLEAN;
BEGIN
    -- Si la actividad tiene incidente asociado
    IF NEW.incidente_id IS NOT NULL THEN
        -- Verificar que el tipo de actividad requiera incidente
        SELECT requiere_incidente INTO requiere_incidente_val
        FROM tipo_actividad
        WHERE id = NEW.tipo_actividad_id;

        IF requiere_incidente_val = FALSE THEN
            RAISE EXCEPTION 'El tipo de actividad "%" no puede estar asociado a un incidente',
                (SELECT nombre FROM tipo_actividad WHERE id = NEW.tipo_actividad_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_actividad_incidente IS 'Valida que las actividades asociadas a incidentes tengan tipo correcto';

CREATE TRIGGER trigger_validar_actividad_incidente
    BEFORE INSERT OR UPDATE ON actividad_unidad
    FOR EACH ROW
    EXECUTE FUNCTION validar_actividad_incidente();

-- ========================================
-- FUNCIÓN: Registrar cambios en auditoría (ejemplo para incidentes)
-- ========================================

CREATE OR REPLACE FUNCTION log_incidente_cambios()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_nuevos, ip_address
        ) VALUES (
            NEW.creado_por, 'INSERT', 'incidente', NEW.id,
            to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, datos_nuevos, ip_address
        ) VALUES (
            NEW.actualizado_por, 'UPDATE', 'incidente', NEW.id,
            to_jsonb(OLD), to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, ip_address
        ) VALUES (
            OLD.actualizado_por, 'DELETE', 'incidente', OLD.id,
            to_jsonb(OLD), inet_client_addr()::TEXT
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION log_incidente_cambios IS 'Registra automáticamente cambios en incidentes en el log de auditoría';

CREATE TRIGGER trigger_log_incidente_cambios
    AFTER INSERT OR UPDATE OR DELETE ON incidente
    FOR EACH ROW
    EXECUTE FUNCTION log_incidente_cambios();
