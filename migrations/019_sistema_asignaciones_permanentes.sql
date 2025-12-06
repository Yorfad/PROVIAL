-- Migración 019: Sistema de Asignaciones Permanentes y Salidas (Opción B)
-- Rediseño completo: Elimina concepto de turnos diarios, implementa asignaciones permanentes

-- ========================================
-- 1. MODIFICAR TABLA USUARIO - Agregar CHAPA
-- ========================================

-- Agregar columna chapa (identificación única de brigadistas)
ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS chapa VARCHAR(20) UNIQUE;

COMMENT ON COLUMN usuario.chapa IS 'Número de chapa del brigadista (ej: 19109, 15056). Se usa como username.';

-- Para brigadistas existentes, copiar username a chapa si no existe
UPDATE usuario
SET chapa = username
WHERE rol_id = (SELECT id FROM rol WHERE codigo = 'BRIGADA')
  AND chapa IS NULL;

-- ========================================
-- 2. TABLA: BRIGADA_UNIDAD (Asignación Permanente)
-- ========================================

CREATE TABLE IF NOT EXISTS brigada_unidad (
    id SERIAL PRIMARY KEY,

    -- Relaciones
    brigada_id INT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,

    -- Rol en la unidad
    rol_tripulacion VARCHAR(30) NOT NULL
        CHECK (rol_tripulacion IN ('PILOTO', 'COPILOTO', 'ACOMPAÑANTE')),

    -- Vigencia
    fecha_asignacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_fin TIMESTAMPTZ, -- NULL = asignación activa
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    -- Observaciones
    observaciones TEXT,
    asignado_por INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE brigada_unidad IS 'Asignaciones permanentes de brigadistas a unidades';
COMMENT ON COLUMN brigada_unidad.activo IS 'TRUE = asignación vigente, FALSE = terminada';
COMMENT ON COLUMN brigada_unidad.fecha_fin IS 'Fecha en que finalizó la asignación (por reasignación, baja, etc.)';

CREATE INDEX idx_brigada_unidad_brigada ON brigada_unidad(brigada_id);
CREATE INDEX idx_brigada_unidad_unidad ON brigada_unidad(unidad_id);
CREATE INDEX idx_brigada_unidad_activo ON brigada_unidad(activo) WHERE activo = TRUE;

-- Un brigadista solo puede estar asignado a una unidad activa a la vez
CREATE UNIQUE INDEX idx_brigada_activa_unica
    ON brigada_unidad(brigada_id)
    WHERE activo = TRUE;

COMMENT ON INDEX idx_brigada_activa_unica IS 'Garantiza que un brigadista solo tenga una asignación activa';

-- Trigger para updated_at
CREATE TRIGGER update_brigada_unidad_updated_at
    BEFORE UPDATE ON brigada_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 3. TABLA: SALIDA_UNIDAD (Reemplaza turnos diarios)
-- ========================================

CREATE TABLE IF NOT EXISTS salida_unidad (
    id SERIAL PRIMARY KEY,

    -- Unidad que sale
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Timing (sin restricción de fecha)
    fecha_hora_salida TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_hora_regreso TIMESTAMPTZ, -- NULL mientras esté en salida

    -- Estado
    estado VARCHAR(30) NOT NULL DEFAULT 'EN_SALIDA'
        CHECK (estado IN ('EN_SALIDA', 'FINALIZADA', 'CANCELADA')),

    -- Datos iniciales
    ruta_inicial_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km_inicial DECIMAL(8,2),
    combustible_inicial DECIMAL(5,2), -- Litros

    -- Datos finales (al regresar)
    km_final DECIMAL(8,2),
    combustible_final DECIMAL(5,2),
    km_recorridos DECIMAL(8,2), -- Calculado: km_final - km_inicial

    -- Tripulación que salió (JSON array de brigadistas)
    -- Formato: [{"brigada_id": 1, "nombre": "Juan", "chapa": "19109", "rol": "PILOTO"}, ...]
    tripulacion JSONB,

    -- Quién finalizó la salida
    finalizada_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    observaciones_salida TEXT,
    observaciones_regreso TEXT,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE salida_unidad IS 'Registro de salidas de unidades. Puede durar horas o días sin límite.';
COMMENT ON COLUMN salida_unidad.estado IS 'EN_SALIDA: activa | FINALIZADA: regresó a sede | CANCELADA: cancelada';
COMMENT ON COLUMN salida_unidad.tripulacion IS 'Brigadistas que salieron en esta salida (snapshot al momento de salir)';
COMMENT ON COLUMN salida_unidad.finalizada_por IS 'Usuario que marcó el regreso (puede ser brigadista, COP, Ops, Admin)';

CREATE INDEX idx_salida_unidad_unidad ON salida_unidad(unidad_id);
CREATE INDEX idx_salida_unidad_estado ON salida_unidad(estado);
CREATE INDEX idx_salida_unidad_fecha ON salida_unidad(fecha_hora_salida DESC);

-- Solo una salida activa por unidad a la vez
CREATE UNIQUE INDEX idx_salida_activa_por_unidad
    ON salida_unidad(unidad_id)
    WHERE estado = 'EN_SALIDA';

COMMENT ON INDEX idx_salida_activa_por_unidad IS 'Garantiza que una unidad solo tenga una salida activa a la vez';

-- Trigger para updated_at
CREATE TRIGGER update_salida_unidad_updated_at
    BEFORE UPDATE ON salida_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 4. MODIFICAR TABLA SITUACION
-- ========================================

-- Agregar FK a salida_unidad
ALTER TABLE situacion
ADD COLUMN IF NOT EXISTS salida_unidad_id INT REFERENCES salida_unidad(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_situacion_salida ON situacion(salida_unidad_id);

COMMENT ON COLUMN situacion.salida_unidad_id IS 'Salida durante la cual se registró esta situación';

-- ========================================
-- 5. TABLA: RELEVO (Para intercambios de unidades/tripulaciones)
-- ========================================

CREATE TABLE IF NOT EXISTS relevo (
    id SERIAL PRIMARY KEY,

    -- Situación donde se registra el relevo
    situacion_id INT REFERENCES situacion(id) ON DELETE CASCADE,

    -- Tipo de relevo
    tipo_relevo VARCHAR(30) NOT NULL
        CHECK (tipo_relevo IN ('UNIDAD_COMPLETA', 'CRUZADO')),

    -- Unidades involucradas
    unidad_saliente_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    unidad_entrante_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Brigadistas que se retiran
    brigadistas_salientes JSONB, -- Array de {brigada_id, chapa, nombre}

    -- Brigadistas que llegan
    brigadistas_entrantes JSONB, -- Array de {brigada_id, chapa, nombre}

    -- Datos adicionales
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observaciones TEXT,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE relevo IS 'Registro de relevos entre unidades/tripulaciones';
COMMENT ON COLUMN relevo.tipo_relevo IS 'UNIDAD_COMPLETA: 016 se va, 015 llega | CRUZADO: tripulación 016 se queda con unidad 015';

CREATE INDEX idx_relevo_situacion ON relevo(situacion_id);
CREATE INDEX idx_relevo_unidad_saliente ON relevo(unidad_saliente_id);
CREATE INDEX idx_relevo_unidad_entrante ON relevo(unidad_entrante_id);
CREATE INDEX idx_relevo_fecha ON relevo(fecha_hora DESC);

-- ========================================
-- 6. VISTAS
-- ========================================

-- Vista: Mi unidad asignada (para app móvil)
CREATE OR REPLACE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,

    -- Unidad asignada
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,

    -- Vigencia
    bu.fecha_asignacion,
    bu.activo,

    -- Compañeros de unidad
    (
        SELECT json_agg(
            json_build_object(
                'brigada_id', u2.id,
                'chapa', u2.chapa,
                'nombre', u2.nombre_completo,
                'rol', bu2.rol_tripulacion
            )
            ORDER BY
                CASE bu2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM brigada_unidad bu2
        JOIN usuario u2 ON bu2.brigada_id = u2.id
        WHERE bu2.unidad_id = bu.unidad_id
          AND bu2.activo = TRUE
          AND bu2.brigada_id != u.id
    ) AS companeros

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id
JOIN unidad un ON bu.unidad_id = un.id
WHERE bu.activo = TRUE;

COMMENT ON VIEW v_mi_unidad_asignada IS 'Unidad asignada permanentemente a un brigadista';

-- Vista: Salida activa de mi unidad
CREATE OR REPLACE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,

    -- Salida
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,

    -- Duración de la salida
    EXTRACT(EPOCH FROM (COALESCE(s.fecha_hora_regreso, NOW()) - s.fecha_hora_salida)) / 3600 AS horas_salida,

    -- Ruta inicial
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,

    -- Tripulación
    s.tripulacion,

    -- Primera situación (debe ser SALIDA_SEDE)
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id;

COMMENT ON VIEW v_mi_salida_activa IS 'Salida activa de la unidad de un brigadista';

-- Vista: Resumen de unidades y sus salidas activas
CREATE OR REPLACE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Salida activa
    s.id AS salida_id,
    s.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - s.fecha_hora_salida)) / 3600 AS horas_en_salida,

    -- Ruta
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,

    -- Tripulación
    s.tripulacion,

    -- Cantidad de situaciones registradas
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
    ) AS total_situaciones,

    -- Última situación
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'km', sit.km,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion

FROM unidad u
JOIN salida_unidad s ON u.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
ORDER BY s.fecha_hora_salida DESC;

COMMENT ON VIEW v_unidades_en_salida IS 'Todas las unidades que actualmente están en salida';

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Iniciar salida de unidad
CREATE OR REPLACE FUNCTION iniciar_salida_unidad(
    p_unidad_id INT,
    p_ruta_inicial_id INT DEFAULT NULL,
    p_km_inicial DECIMAL DEFAULT NULL,
    p_combustible_inicial DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_salida_id INT;
    v_tripulacion JSONB;
    v_salida_existente INT;
BEGIN
    -- Verificar que no haya salida activa
    SELECT id INTO v_salida_existente
    FROM salida_unidad
    WHERE unidad_id = p_unidad_id
      AND estado = 'EN_SALIDA';

    IF v_salida_existente IS NOT NULL THEN
        RAISE EXCEPTION 'La unidad ya tiene una salida activa (ID: %)', v_salida_existente;
    END IF;

    -- Obtener tripulación actual de la unidad
    SELECT json_agg(
        json_build_object(
            'brigada_id', u.id,
            'chapa', u.chapa,
            'nombre', u.nombre_completo,
            'rol', bu.rol_tripulacion
        )
        ORDER BY
            CASE bu.rol_tripulacion
                WHEN 'PILOTO' THEN 1
                WHEN 'COPILOTO' THEN 2
                WHEN 'ACOMPAÑANTE' THEN 3
            END
    )
    INTO v_tripulacion
    FROM brigada_unidad bu
    JOIN usuario u ON bu.brigada_id = u.id
    WHERE bu.unidad_id = p_unidad_id
      AND bu.activo = TRUE;

    -- Crear salida
    INSERT INTO salida_unidad (
        unidad_id,
        ruta_inicial_id,
        km_inicial,
        combustible_inicial,
        tripulacion,
        observaciones_salida,
        estado
    )
    VALUES (
        p_unidad_id,
        p_ruta_inicial_id,
        p_km_inicial,
        p_combustible_inicial,
        v_tripulacion,
        p_observaciones,
        'EN_SALIDA'
    )
    RETURNING id INTO v_salida_id;

    RETURN v_salida_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION iniciar_salida_unidad IS 'Inicia una nueva salida para una unidad. Crea snapshot de tripulación actual.';

-- Función: Finalizar salida de unidad
CREATE OR REPLACE FUNCTION finalizar_salida_unidad(
    p_salida_id INT,
    p_km_final DECIMAL DEFAULT NULL,
    p_combustible_final DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_finalizada_por INT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_km_inicial DECIMAL;
    v_km_recorridos DECIMAL;
BEGIN
    -- Obtener km inicial
    SELECT km_inicial INTO v_km_inicial
    FROM salida_unidad
    WHERE id = p_salida_id;

    -- Calcular km recorridos
    IF p_km_final IS NOT NULL AND v_km_inicial IS NOT NULL THEN
        v_km_recorridos := ABS(p_km_final - v_km_inicial);
    END IF;

    -- Finalizar salida
    UPDATE salida_unidad
    SET estado = 'FINALIZADA',
        fecha_hora_regreso = NOW(),
        km_final = p_km_final,
        combustible_final = p_combustible_final,
        km_recorridos = v_km_recorridos,
        observaciones_regreso = p_observaciones,
        finalizada_por = p_finalizada_por
    WHERE id = p_salida_id
      AND estado = 'EN_SALIDA';

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION finalizar_salida_unidad IS 'Finaliza una salida activa. Calcula km recorridos automáticamente.';

-- Función: Verificar que primera situación sea SALIDA_SEDE
CREATE OR REPLACE FUNCTION verificar_primera_situacion_es_salida()
RETURNS TRIGGER AS $$
DECLARE
    v_count_situaciones INT;
BEGIN
    -- Contar situaciones existentes de esta salida
    SELECT COUNT(*)
    INTO v_count_situaciones
    FROM situacion
    WHERE salida_unidad_id = NEW.salida_unidad_id;

    -- Si es la primera situación y NO es SALIDA_SEDE, rechazar
    IF v_count_situaciones = 0 AND NEW.tipo_situacion != 'SALIDA_SEDE' THEN
        RAISE EXCEPTION 'La primera situación de una salida DEBE ser SALIDA_SEDE. Tipo recibido: %', NEW.tipo_situacion;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_primera_situacion
    BEFORE INSERT ON situacion
    FOR EACH ROW
    WHEN (NEW.salida_unidad_id IS NOT NULL)
    EXECUTE FUNCTION verificar_primera_situacion_es_salida();

COMMENT ON FUNCTION verificar_primera_situacion_es_salida IS 'Fuerza que la primera situación de una salida sea SALIDA_SEDE';

-- ========================================
-- 8. DATOS DE EJEMPLO (OPCIONAL - COMENTADO)
-- ========================================

/*
-- Asignar brigada01 a unidad PROV-001 como PILOTO
INSERT INTO brigada_unidad (brigada_id, unidad_id, rol_tripulacion, asignado_por)
SELECT
    u.id,
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    'PILOTO',
    u.id
FROM usuario u
WHERE u.username = 'brigada01';

-- Iniciar salida de PROV-001
SELECT iniciar_salida_unidad(
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    0.0,
    30.0,
    'Salida de prueba'
);
*/
