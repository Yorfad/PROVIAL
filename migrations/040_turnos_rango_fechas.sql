-- Migración 040: Soporte para rangos de fecha en turnos y mejoras en asignaciones
-- Cambios:
-- 1. Agregar fecha_fin a turno para comisiones largas
-- 2. Modificar vista v_mi_asignacion_hoy para mostrar próxima asignación (no solo hoy)
-- 3. Crear función de validación para evitar duplicar unidad en mismo día

-- =============================================
-- 1. AGREGAR FECHA_FIN A TURNO
-- =============================================

-- Agregar columna fecha_fin (opcional - si es NULL, el turno es de un solo día)
ALTER TABLE turno ADD COLUMN IF NOT EXISTS fecha_fin DATE;

-- Comentario
COMMENT ON COLUMN turno.fecha_fin IS 'Fecha de fin del turno. Si es NULL, el turno es de un solo día (fecha)';

-- Remover el constraint UNIQUE de fecha para permitir múltiples turnos
-- (La validación se hará por unidad, no por fecha global)
ALTER TABLE turno DROP CONSTRAINT IF EXISTS turno_fecha_key;

-- =============================================
-- 2. MODIFICAR VISTA v_mi_asignacion_hoy
-- =============================================

-- Ahora muestra la próxima asignación del brigada (hoy o futura)
-- Ordenado por fecha más cercana
DROP VIEW IF EXISTS v_mi_asignacion_hoy;

CREATE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    CASE
        WHEN a.km_inicio IS NOT NULL AND a.km_final IS NOT NULL
            THEN 'Km ' || a.km_inicio || ' - Km ' || a.km_final
        WHEN a.km_inicio IS NOT NULL THEN 'Desde Km ' || a.km_inicio
        WHEN a.km_final IS NOT NULL THEN 'Hasta Km ' || a.km_final
        ELSE NULL
    END AS recorrido_permitido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    -- Calcular días hasta la asignación
    CASE
        WHEN t.fecha = CURRENT_DATE THEN 0
        ELSE t.fecha - CURRENT_DATE
    END AS dias_para_salida,
    -- Compañeros de brigada
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', u2.id,
                'nombre', u2.nombre_completo,
                'chapa', u2.chapa,
                'rol', tc2.rol_tripulacion,
                'telefono', u2.telefono
            ) ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                    ELSE 4
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
        AND tc2.usuario_id <> usr.id
    ) AS companeros
FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE
    -- Mostrar asignaciones de hoy en adelante (no pasadas)
    (t.fecha >= CURRENT_DATE OR (t.fecha_fin IS NOT NULL AND t.fecha_fin >= CURRENT_DATE))
    -- Solo turnos planificados o activos
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
    -- No mostrar asignaciones que ya finalizaron (tienen hora_entrada_real)
    AND a.hora_entrada_real IS NULL;

COMMENT ON VIEW v_mi_asignacion_hoy IS 'Muestra la próxima asignación del brigada (hoy o futura). Incluye compañeros, ruta y detalles.';

-- =============================================
-- 3. FUNCIÓN PARA VALIDAR DISPONIBILIDAD DE UNIDAD
-- =============================================

-- Esta función verifica si una unidad ya está asignada en un rango de fechas
CREATE OR REPLACE FUNCTION validar_disponibilidad_unidad_fecha(
    p_unidad_id INTEGER,
    p_fecha_inicio DATE,
    p_fecha_fin DATE DEFAULT NULL,
    p_excluir_asignacion_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    disponible BOOLEAN,
    mensaje TEXT,
    asignacion_conflicto_id INTEGER,
    turno_conflicto_fecha DATE
) AS $$
DECLARE
    v_fecha_fin DATE;
    v_conflicto RECORD;
BEGIN
    -- Si no hay fecha_fin, usar fecha_inicio
    v_fecha_fin := COALESCE(p_fecha_fin, p_fecha_inicio);

    -- Buscar conflictos
    SELECT a.id, t.fecha, t.fecha_fin, u.codigo
    INTO v_conflicto
    FROM asignacion_unidad a
    JOIN turno t ON a.turno_id = t.id
    JOIN unidad u ON a.unidad_id = u.id
    WHERE a.unidad_id = p_unidad_id
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
    AND a.hora_entrada_real IS NULL  -- No ha finalizado
    AND (p_excluir_asignacion_id IS NULL OR a.id <> p_excluir_asignacion_id)
    -- Verificar solapamiento de fechas
    AND (
        -- El rango solicitado se solapa con el rango existente
        (p_fecha_inicio <= COALESCE(t.fecha_fin, t.fecha) AND v_fecha_fin >= t.fecha)
    )
    LIMIT 1;

    IF v_conflicto.id IS NOT NULL THEN
        RETURN QUERY SELECT
            FALSE,
            'La unidad ya está asignada para el ' ||
                CASE
                    WHEN v_conflicto.fecha_fin IS NOT NULL
                    THEN 'período ' || v_conflicto.fecha || ' al ' || v_conflicto.fecha_fin
                    ELSE 'día ' || v_conflicto.fecha
                END,
            v_conflicto.id,
            v_conflicto.fecha;
    ELSE
        RETURN QUERY SELECT
            TRUE,
            'Unidad disponible'::TEXT,
            NULL::INTEGER,
            NULL::DATE;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_disponibilidad_unidad_fecha IS
'Valida si una unidad está disponible para un rango de fechas. Evita asignar la misma unidad dos veces en días que se solapan.';

-- =============================================
-- 4. TRIGGER PARA VALIDAR ANTES DE INSERTAR ASIGNACIÓN
-- =============================================

CREATE OR REPLACE FUNCTION trigger_validar_asignacion_unidad()
RETURNS TRIGGER AS $$
DECLARE
    v_fecha DATE;
    v_fecha_fin DATE;
    v_validacion RECORD;
BEGIN
    -- Obtener fechas del turno
    SELECT t.fecha, t.fecha_fin INTO v_fecha, v_fecha_fin
    FROM turno t WHERE t.id = NEW.turno_id;

    -- Validar disponibilidad
    SELECT * INTO v_validacion
    FROM validar_disponibilidad_unidad_fecha(
        NEW.unidad_id,
        v_fecha,
        v_fecha_fin,
        CASE WHEN TG_OP = 'UPDATE' THEN OLD.id ELSE NULL END
    );

    IF NOT v_validacion.disponible THEN
        RAISE EXCEPTION 'No se puede asignar la unidad: %', v_validacion.mensaje;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger si no existe
DROP TRIGGER IF EXISTS trg_validar_asignacion_unidad ON asignacion_unidad;
CREATE TRIGGER trg_validar_asignacion_unidad
    BEFORE INSERT OR UPDATE OF unidad_id, turno_id ON asignacion_unidad
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validar_asignacion_unidad();

-- =============================================
-- 5. VISTA PARA ASIGNACIONES PENDIENTES (OPERACIONES)
-- =============================================

DROP VIEW IF EXISTS v_asignaciones_pendientes;

CREATE VIEW v_asignaciones_pendientes AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.sentido,
    a.hora_salida,
    a.hora_salida_real,
    a.acciones,
    CASE
        WHEN t.fecha = CURRENT_DATE THEN 'HOY'
        WHEN t.fecha = CURRENT_DATE + 1 THEN 'MAÑANA'
        ELSE t.fecha::TEXT
    END AS dia_salida,
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', usr.id,
                'nombre', usr.nombre_completo,
                'chapa', usr.chapa,
                'rol', tc.rol_tripulacion
            ) ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                    ELSE 4
                END
        )
        FROM tripulacion_turno tc
        JOIN usuario usr ON tc.usuario_id = usr.id
        WHERE tc.asignacion_id = a.id
    ) AS tripulacion
FROM turno t
JOIN asignacion_unidad a ON t.id = a.turno_id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE
    (t.fecha >= CURRENT_DATE OR (t.fecha_fin IS NOT NULL AND t.fecha_fin >= CURRENT_DATE))
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
ORDER BY t.fecha, a.hora_salida;

COMMENT ON VIEW v_asignaciones_pendientes IS 'Lista de asignaciones pendientes para operaciones (hoy y futuras)';

-- Confirmar
SELECT 'Migración 040 completada: soporte para rangos de fecha y validación de unidades' AS resultado;
