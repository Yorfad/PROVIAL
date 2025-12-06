-- ========================================
-- Migración 026: Mejoras al Módulo de Operaciones
-- ========================================
-- Cambios principales:
-- 1. Agregar teléfono de contacto a usuarios y tripulación
-- 2. Control de combustible mejorado
-- 3. Permitir turnos planificados con fecha específica (no solo hoy)
-- 4. Alertas de descanso para brigadas
-- 5. Multi-sede (cada operaciones ve sus recursos)
-- ========================================

-- ========================================
-- 1. VERIFICAR COLUMNA TELÉFONO EN USUARIOS
-- ========================================

-- La columna telefono ya existe en usuario (creada en migración 002)
-- Solo agregamos un índice si no existe

CREATE INDEX IF NOT EXISTS idx_usuario_telefono ON usuario(telefono) WHERE telefono IS NOT NULL;

-- ========================================
-- 2. AGREGAR COMBUSTIBLE ACTUAL A UNIDAD
-- ========================================

ALTER TABLE unidad
ADD COLUMN IF NOT EXISTS combustible_actual DECIMAL(6,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS capacidad_combustible DECIMAL(6,2),
ADD COLUMN IF NOT EXISTS odometro_actual DECIMAL(10,2) DEFAULT 0;

COMMENT ON COLUMN unidad.combustible_actual IS 'Combustible actual en litros (actualizado por brigadas)';
COMMENT ON COLUMN unidad.capacidad_combustible IS 'Capacidad total del tanque en litros';
COMMENT ON COLUMN unidad.odometro_actual IS 'Kilometraje total del vehículo';

CREATE INDEX IF NOT EXISTS idx_unidad_combustible ON unidad(combustible_actual) WHERE activa = TRUE;

-- ========================================
-- 3. TABLA: COMBUSTIBLE_REGISTRO
-- ========================================

CREATE TABLE IF NOT EXISTS combustible_registro (
    id BIGSERIAL PRIMARY KEY,

    -- Relaciones
    unidad_id INTEGER NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,
    asignacion_id INTEGER REFERENCES asignacion_unidad(id) ON DELETE SET NULL,
    turno_id INTEGER REFERENCES turno(id) ON DELETE SET NULL,

    -- Tipo de registro
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('INICIAL', 'RECARGA', 'FINAL', 'AJUSTE')),

    -- Cantidades
    combustible_anterior DECIMAL(6,2) NOT NULL,
    combustible_agregado DECIMAL(6,2) DEFAULT 0,
    combustible_nuevo DECIMAL(6,2) NOT NULL,
    combustible_consumido DECIMAL(6,2), -- Calculado para tipo FINAL

    -- Odómetro
    odometro_anterior DECIMAL(10,2),
    odometro_actual DECIMAL(10,2),
    km_recorridos DECIMAL(8,2),

    -- Eficiencia
    rendimiento_km_litro DECIMAL(6,2), -- km/litro calculado

    -- Metadata
    observaciones TEXT,
    registrado_por INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE combustible_registro IS 'Historial detallado de combustible por unidad y turno';
COMMENT ON COLUMN combustible_registro.tipo IS 'INICIAL: al iniciar turno | RECARGA: durante turno | FINAL: al terminar turno | AJUSTE: corrección manual';
COMMENT ON COLUMN combustible_registro.rendimiento_km_litro IS 'Rendimiento calculado (km_recorridos / combustible_consumido)';

CREATE INDEX idx_combustible_unidad ON combustible_registro(unidad_id);
CREATE INDEX idx_combustible_asignacion ON combustible_registro(asignacion_id);
CREATE INDEX idx_combustible_turno ON combustible_registro(turno_id);
CREATE INDEX idx_combustible_tipo ON combustible_registro(tipo);
CREATE INDEX idx_combustible_created ON combustible_registro(created_at DESC);

-- Trigger para actualizar combustible actual de unidad
CREATE OR REPLACE FUNCTION update_combustible_unidad()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE unidad
    SET
        combustible_actual = NEW.combustible_nuevo,
        odometro_actual = COALESCE(NEW.odometro_actual, odometro_actual),
        updated_at = NOW()
    WHERE id = NEW.unidad_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_combustible_unidad
AFTER INSERT ON combustible_registro
FOR EACH ROW
EXECUTE FUNCTION update_combustible_unidad();

COMMENT ON FUNCTION update_combustible_unidad IS 'Actualiza automáticamente el combustible actual de la unidad';

-- ========================================
-- 4. AGREGAR TELÉFONO DE CONTACTO A TRIPULACIÓN
-- ========================================

ALTER TABLE tripulacion_turno
ADD COLUMN IF NOT EXISTS telefono_contacto VARCHAR(20);

COMMENT ON COLUMN tripulacion_turno.telefono_contacto IS 'Teléfono de contacto para este turno específico (puede diferir del usuario)';

-- ========================================
-- 5. AGREGAR NOTIFICACIÓN ENVIADA
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN IF NOT EXISTS notificacion_enviada BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS fecha_notificacion TIMESTAMPTZ;

COMMENT ON COLUMN asignacion_unidad.notificacion_enviada IS 'Si ya se notificó a la tripulación de esta asignación';

-- ========================================
-- 6. VISTA: ESTADÍSTICAS DE BRIGADAS
-- ========================================

CREATE OR REPLACE VIEW v_estadisticas_brigadas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.sede_id,
    s.nombre AS sede_nombre,
    r.nombre AS rol_nombre,

    -- Contadores
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,

    -- Último turno
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_turno,

    -- Próximo turno
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,

    -- Roles más frecuentes en tripulación
    MODE() WITHIN GROUP (ORDER BY tt.rol_tripulacion) AS rol_tripulacion_frecuente,

    -- Estado
    u.activo

FROM usuario u
INNER JOIN sede s ON u.sede_id = s.id
INNER JOIN rol r ON u.rol_id = r.id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
WHERE r.nombre = 'BRIGADA'
GROUP BY u.id, u.nombre_completo, u.chapa, u.telefono, u.sede_id, s.nombre, r.nombre, u.activo;

COMMENT ON VIEW v_estadisticas_brigadas IS 'Estadísticas de turnos y disponibilidad por brigada';

-- ========================================
-- 7. VISTA: ESTADÍSTICAS DE UNIDADES
-- ========================================

CREATE OR REPLACE VIEW v_estadisticas_unidades AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    un.marca,
    un.modelo,
    un.sede_id,
    s.nombre AS sede_nombre,

    -- Estado actual
    un.activa,
    un.combustible_actual,
    un.capacidad_combustible,
    un.odometro_actual,

    -- Contadores de uso
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,

    -- Último uso
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_uso,

    -- Próximo turno
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,

    -- Combustible
    AVG(cr.combustible_consumido) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS consumo_promedio_diario,
    AVG(cr.rendimiento_km_litro) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS rendimiento_promedio,

    -- Kilometraje
    SUM(au.km_recorridos) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS km_ultimo_mes

FROM unidad un
INNER JOIN sede s ON un.sede_id = s.id
LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN combustible_registro cr ON un.id = cr.unidad_id AND cr.tipo = 'FINAL'
GROUP BY un.id, un.codigo, un.tipo_unidad, un.marca, un.modelo, un.sede_id, s.nombre;

COMMENT ON VIEW v_estadisticas_unidades IS 'Estadísticas de uso y combustible por unidad';

-- ========================================
-- 8. VISTA: DISPONIBILIDAD DE RECURSOS
-- ========================================

CREATE OR REPLACE VIEW v_disponibilidad_recursos AS
SELECT
    s.id AS sede_id,
    s.nombre AS sede_nombre,

    -- Brigadas
    COUNT(DISTINCT u.id) FILTER (WHERE r.nombre = 'BRIGADA' AND u.activo = TRUE) AS total_brigadas_activas,
    COUNT(DISTINCT tt.usuario_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
        AND r.nombre = 'BRIGADA'
        AND u.activo = TRUE
    ) AS brigadas_en_turno_hoy,

    -- Unidades
    COUNT(DISTINCT un.id) FILTER (WHERE un.activa = TRUE) AS total_unidades_activas,
    COUNT(DISTINCT au.unidad_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
    ) AS unidades_en_turno_hoy,

    -- Disponibles
    COUNT(DISTINCT u.id) FILTER (
        WHERE r.nombre = 'BRIGADA'
        AND u.activo = TRUE
        AND u.id NOT IN (
            SELECT tt2.usuario_id
            FROM tripulacion_turno tt2
            JOIN asignacion_unidad au2 ON tt2.asignacion_id = au2.id
            JOIN turno t2 ON au2.turno_id = t2.id
            WHERE t2.fecha = CURRENT_DATE
        )
    ) AS brigadas_disponibles_hoy,

    COUNT(DISTINCT un.id) FILTER (
        WHERE un.activa = TRUE
        AND un.id NOT IN (
            SELECT au3.unidad_id
            FROM asignacion_unidad au3
            JOIN turno t3 ON au3.turno_id = t3.id
            WHERE t3.fecha = CURRENT_DATE
        )
    ) AS unidades_disponibles_hoy

FROM sede s
LEFT JOIN usuario u ON s.id = u.sede_id
LEFT JOIN rol r ON u.rol_id = r.id
LEFT JOIN unidad un ON s.id = un.sede_id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id AND un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
GROUP BY s.id, s.nombre;

COMMENT ON VIEW v_disponibilidad_recursos IS 'Resumen de disponibilidad de recursos por sede';

-- ========================================
-- 9. FUNCIÓN: VALIDAR DISPONIBILIDAD BRIGADA
-- ========================================

CREATE OR REPLACE FUNCTION validar_disponibilidad_brigada(
    p_usuario_id INTEGER,
    p_fecha DATE
)
RETURNS TABLE (
    disponible BOOLEAN,
    mensaje TEXT,
    ultimo_turno_fecha DATE,
    dias_descanso INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN COUNT(au.id) > 0 THEN FALSE -- Ya tiene turno ese día
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) < 2 THEN FALSE -- Salió hace menos de 2 días
            ELSE TRUE
        END AS disponible,

        CASE
            WHEN COUNT(au.id) > 0 THEN 'Brigada ya tiene asignación para esta fecha'
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) = 0 THEN 'Brigada sale el mismo día'
            WHEN MAX(t.fecha) IS NOT NULL
                 AND (p_fecha - MAX(t.fecha)) = 1 THEN 'Brigada salió ayer - descanso recomendado'
            ELSE 'Brigada disponible'
        END AS mensaje,

        MAX(t.fecha) AS ultimo_turno_fecha,
        COALESCE(p_fecha - MAX(t.fecha), 999) AS dias_descanso

    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    WHERE tt.usuario_id = p_usuario_id
      AND (
          t.fecha = p_fecha
          OR t.fecha >= p_fecha - INTERVAL '7 days'
      )
    GROUP BY tt.usuario_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_disponibilidad_brigada IS 'Valida si una brigada está disponible para una fecha y retorna alertas';

-- ========================================
-- 10. FUNCIÓN: VALIDAR DISPONIBILIDAD UNIDAD
-- ========================================

CREATE OR REPLACE FUNCTION validar_disponibilidad_unidad(
    p_unidad_id INTEGER,
    p_fecha DATE
)
RETURNS TABLE (
    disponible BOOLEAN,
    mensaje TEXT,
    ultimo_uso_fecha DATE,
    dias_descanso INTEGER,
    combustible_suficiente BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN COUNT(au.id) > 0 THEN FALSE -- Ya está asignada ese día
            WHEN un.activa = FALSE THEN FALSE -- Unidad inactiva
            WHEN un.combustible_actual < 10 THEN FALSE -- Poco combustible
            ELSE TRUE
        END AS disponible,

        CASE
            WHEN COUNT(au.id) > 0 THEN 'Unidad ya asignada para esta fecha'
            WHEN un.activa = FALSE THEN 'Unidad está inactiva'
            WHEN un.combustible_actual < 10 THEN 'Combustible insuficiente (menos de 10L)'
            ELSE 'Unidad disponible'
        END AS mensaje,

        MAX(t.fecha) AS ultimo_uso_fecha,
        COALESCE(p_fecha - MAX(t.fecha), 999) AS dias_descanso,
        COALESCE(un.combustible_actual >= 10, FALSE) AS combustible_suficiente

    FROM unidad un
    LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
    LEFT JOIN turno t ON au.turno_id = t.id AND (t.fecha = p_fecha OR t.fecha >= p_fecha - INTERVAL '7 days')
    WHERE un.id = p_unidad_id
    GROUP BY un.id, un.activa, un.combustible_actual;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_disponibilidad_unidad IS 'Valida si una unidad está disponible para una fecha';

-- ========================================
-- 11. ÍNDICES ADICIONALES PARA PERFORMANCE
-- ========================================

CREATE INDEX IF NOT EXISTS idx_turno_fecha_estado ON turno(fecha, estado);
CREATE INDEX IF NOT EXISTS idx_asignacion_turno_unidad ON asignacion_unidad(turno_id, unidad_id);
CREATE INDEX IF NOT EXISTS idx_tripulacion_usuario_fecha ON tripulacion_turno(usuario_id, created_at);

-- ========================================
-- GRANTS (si es necesario)
-- ========================================

-- Los usuarios de operaciones deben poder gestionar turnos
-- GRANT SELECT, INSERT, UPDATE ON turno TO operaciones_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON asignacion_unidad TO operaciones_role;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON tripulacion_turno TO operaciones_role;
