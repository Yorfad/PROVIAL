-- Migración 018: Mejoras al sistema de rutas y combustible

-- ========================================
-- 1. AGREGAR RUTA ACTIVA A ASIGNACION
-- ========================================

-- Agregar campo para rastrear la ruta activa durante el día
ALTER TABLE asignacion_unidad
ADD COLUMN IF NOT EXISTS ruta_activa_id INT REFERENCES ruta(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS hora_ultima_actualizacion_ruta TIMESTAMPTZ;

COMMENT ON COLUMN asignacion_unidad.ruta_activa_id IS 'Ruta actualmente activa para esta asignación (se define en SALIDA_SEDE o CAMBIO_RUTA)';
COMMENT ON COLUMN asignacion_unidad.hora_ultima_actualizacion_ruta IS 'Última vez que se actualizó la ruta activa';

-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_asignacion_ruta_activa ON asignacion_unidad(ruta_activa_id) WHERE ruta_activa_id IS NOT NULL;

-- ========================================
-- 2. MEJORAR CAMPO DE COMBUSTIBLE EN SITUACION
-- ========================================

-- Agregar campo para guardar la fracción como texto
ALTER TABLE situacion
ADD COLUMN IF NOT EXISTS combustible_fraccion VARCHAR(10);

COMMENT ON COLUMN situacion.combustible IS 'Nivel de combustible como decimal (0.0 a 1.0)';
COMMENT ON COLUMN situacion.combustible_fraccion IS 'Fracción de combustible legible (ej: 1/2, 3/4, 7/8, LLENO)';

-- ========================================
-- 3. FUNCIÓN: OBTENER RUTA ACTIVA DE UNA ASIGNACIÓN
-- ========================================

CREATE OR REPLACE FUNCTION obtener_ruta_activa(p_asignacion_id INT)
RETURNS INT AS $$
DECLARE
    v_ruta_activa_id INT;
BEGIN
    -- Obtener la ruta activa de la asignación
    SELECT ruta_activa_id INTO v_ruta_activa_id
    FROM asignacion_unidad
    WHERE id = p_asignacion_id;

    -- Si no hay ruta activa, usar la ruta asignada por defecto
    IF v_ruta_activa_id IS NULL THEN
        SELECT ruta_id INTO v_ruta_activa_id
        FROM asignacion_unidad
        WHERE id = p_asignacion_id;
    END IF;

    RETURN v_ruta_activa_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_ruta_activa IS 'Obtiene la ruta activa de una asignación, o la ruta por defecto si no hay activa';

-- ========================================
-- 4. FUNCIÓN: ACTUALIZAR RUTA ACTIVA
-- ========================================

CREATE OR REPLACE FUNCTION actualizar_ruta_activa(
    p_asignacion_id INT,
    p_nueva_ruta_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE asignacion_unidad
    SET
        ruta_activa_id = p_nueva_ruta_id,
        hora_ultima_actualizacion_ruta = NOW()
    WHERE id = p_asignacion_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION actualizar_ruta_activa IS 'Actualiza la ruta activa de una asignación (se llama en SALIDA_SEDE o CAMBIO_RUTA)';

-- ========================================
-- 5. TRIGGER: ACTUALIZAR RUTA ACTIVA EN SITUACIONES ESPECIALES
-- ========================================

CREATE OR REPLACE FUNCTION trigger_actualizar_ruta_activa()
RETURNS TRIGGER AS $$
BEGIN
    -- Si es SALIDA_SEDE o CAMBIO_RUTA, actualizar la ruta activa
    IF NEW.tipo_situacion IN ('SALIDA_SEDE', 'CAMBIO_RUTA') THEN
        IF NEW.ruta_id IS NOT NULL AND NEW.asignacion_id IS NOT NULL THEN
            PERFORM actualizar_ruta_activa(NEW.asignacion_id, NEW.ruta_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_situacion_actualizar_ruta_activa'
    ) THEN
        CREATE TRIGGER trigger_situacion_actualizar_ruta_activa
            AFTER INSERT ON situacion
            FOR EACH ROW
            EXECUTE FUNCTION trigger_actualizar_ruta_activa();
    END IF;
END $$;

COMMENT ON TRIGGER trigger_situacion_actualizar_ruta_activa ON situacion IS 'Actualiza automáticamente la ruta activa cuando se crea SALIDA_SEDE o CAMBIO_RUTA';

-- ========================================
-- 6. VISTA MEJORADA: SITUACIONES CON CONSUMO DE COMBUSTIBLE
-- ========================================

CREATE OR REPLACE VIEW v_situaciones_con_combustible AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.created_at,

    -- Calcular consumo vs situación anterior
    LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS combustible_anterior,
    s.combustible - LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS consumo,

    -- Calcular km recorridos
    s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS km_recorridos,

    -- Tiempo desde última situación
    EXTRACT(EPOCH FROM (s.created_at - LAG(s.created_at) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at))) / 60 AS minutos_desde_anterior,

    s.turno_id,
    t.fecha AS turno_fecha
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.combustible IS NOT NULL
ORDER BY s.unidad_id, s.created_at;

COMMENT ON VIEW v_situaciones_con_combustible IS 'Vista de situaciones con análisis de consumo de combustible y km recorridos';

-- ========================================
-- 7. DATOS INICIALES: COPIAR RUTA ASIGNADA COMO RUTA ACTIVA
-- ========================================

-- Para asignaciones existentes, copiar ruta_id a ruta_activa_id
UPDATE asignacion_unidad
SET ruta_activa_id = ruta_id,
    hora_ultima_actualizacion_ruta = created_at
WHERE ruta_id IS NOT NULL
  AND ruta_activa_id IS NULL;

-- ========================================
-- 8. FUNCIÓN: OBTENER HISTORIAL DE COMBUSTIBLE DE UNA UNIDAD
-- ========================================

CREATE OR REPLACE FUNCTION obtener_historial_combustible(
    p_unidad_id INT,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    hora TIMESTAMPTZ,
    tipo_situacion VARCHAR,
    combustible_fraccion VARCHAR,
    combustible_decimal DECIMAL,
    consumo DECIMAL,
    km_recorridos DECIMAL,
    ubicacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.created_at AS hora,
        s.tipo_situacion,
        s.combustible_fraccion,
        s.combustible AS combustible_decimal,
        s.combustible - LAG(s.combustible) OVER (ORDER BY s.created_at) AS consumo,
        s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (ORDER BY s.created_at) AS km_recorridos,
        CONCAT(r.codigo, ' Km ', s.km) AS ubicacion
    FROM situacion s
    LEFT JOIN ruta r ON s.ruta_id = r.id
    LEFT JOIN turno t ON s.turno_id = t.id
    WHERE s.unidad_id = p_unidad_id
      AND t.fecha = p_fecha
      AND s.combustible IS NOT NULL
    ORDER BY s.created_at;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_historial_combustible IS 'Obtiene el historial de combustible de una unidad para un día específico';

-- ========================================
-- FIN DE MIGRACIÓN 018
-- ========================================
