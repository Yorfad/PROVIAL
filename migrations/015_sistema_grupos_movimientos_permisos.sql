-- Migración 015: Sistema de grupos de brigadas, movimientos y permisos dinámicos

-- ========================================
-- MODIFICAR TABLA USUARIO: Agregar grupos
-- ========================================

ALTER TABLE usuario
ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2)),
ADD COLUMN fecha_inicio_ciclo DATE,  -- Fecha en que inició su ciclo actual (para calcular si está de turno)
ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;  -- Permiso individual de acceso

COMMENT ON COLUMN usuario.grupo IS 'Grupo de trabajo: 1 o 2 (8 días trabajo, 8 días descanso)';
COMMENT ON COLUMN usuario.fecha_inicio_ciclo IS 'Fecha de inicio del ciclo actual (para calcular turnos)';
COMMENT ON COLUMN usuario.acceso_app_activo IS 'Si el usuario tiene acceso activo a la app (controlado por COP)';

-- Índice para búsquedas por grupo
CREATE INDEX idx_usuario_grupo ON usuario(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX idx_usuario_acceso ON usuario(acceso_app_activo);

-- ========================================
-- TABLA: CALENDARIO_GRUPOS
-- ========================================

CREATE TABLE calendario_grupo (
    id SERIAL PRIMARY KEY,
    grupo SMALLINT NOT NULL CHECK (grupo IN (1, 2)),
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('TRABAJO', 'DESCANSO')),
    observaciones TEXT,

    -- Auditoría
    creado_por INT REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un solo estado por grupo por fecha
    UNIQUE(grupo, fecha)
);

COMMENT ON TABLE calendario_grupo IS 'Calendario de trabajo/descanso por grupo de brigadas';
COMMENT ON COLUMN calendario_grupo.estado IS 'TRABAJO: Grupo de turno | DESCANSO: Grupo descansando';

CREATE INDEX idx_calendario_grupo_fecha ON calendario_grupo(grupo, fecha DESC);
CREATE INDEX idx_calendario_grupo_estado ON calendario_grupo(estado, fecha);

-- ========================================
-- TABLA: MOVIMIENTO_BRIGADA
-- ========================================

CREATE TABLE movimiento_brigada (
    id BIGSERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    -- Origen del movimiento
    origen_asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    origen_unidad_id INT REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Destino del movimiento (puede ser NULL si es retiro o división de fuerza estática)
    destino_asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    destino_unidad_id INT REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Tipo de movimiento
    tipo_movimiento VARCHAR(30) NOT NULL CHECK (tipo_movimiento IN (
        'CAMBIO_UNIDAD',      -- Cambio completo de unidad
        'PRESTAMO',           -- Préstamo temporal a otra unidad
        'DIVISION_FUERZA',    -- División: algunos se quedan en punto fijo
        'RELEVO',             -- Relevo de turno (ej: nocturno reemplaza diurno)
        'RETIRO',             -- Fin de turno y retiro
        'APOYO_TEMPORAL'      -- Apoyo temporal sin cambiar asignación principal
    )),

    -- Ubicación del movimiento
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),

    -- Tiempos
    hora_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    hora_fin TIMESTAMPTZ,  -- NULL si aún está en ese estado

    -- Información adicional
    motivo TEXT,  -- "Apoyo en accidente", "Compra de comida", "Punto fijo km 43", etc.
    rol_en_destino VARCHAR(30),  -- 'PILOTO', 'COPILOTO', 'ACOMPAÑANTE', 'APOYO'

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE movimiento_brigada IS 'Registro de todos los movimientos de brigadas: cambios, préstamos, divisiones de fuerza';
COMMENT ON COLUMN movimiento_brigada.tipo_movimiento IS 'Tipo de movimiento realizado';
COMMENT ON COLUMN movimiento_brigada.hora_fin IS 'NULL si el movimiento aún está activo';
COMMENT ON COLUMN movimiento_brigada.motivo IS 'Razón del movimiento';

-- Índices
CREATE INDEX idx_movimiento_usuario ON movimiento_brigada(usuario_id);
CREATE INDEX idx_movimiento_turno ON movimiento_brigada(turno_id);
CREATE INDEX idx_movimiento_origen ON movimiento_brigada(origen_asignacion_id);
CREATE INDEX idx_movimiento_destino ON movimiento_brigada(destino_asignacion_id);
CREATE INDEX idx_movimiento_tipo ON movimiento_brigada(tipo_movimiento);
CREATE INDEX idx_movimiento_activo ON movimiento_brigada(hora_fin) WHERE hora_fin IS NULL;
CREATE INDEX idx_movimiento_fecha ON movimiento_brigada(created_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_movimiento_brigada_updated_at
    BEFORE UPDATE ON movimiento_brigada
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: CONTROL_ACCESO_APP
-- ========================================

CREATE TABLE control_acceso_app (
    id SERIAL PRIMARY KEY,

    -- Control puede ser por: usuario individual, grupo, unidad o sede
    usuario_id INT REFERENCES usuario(id) ON DELETE CASCADE,
    grupo SMALLINT CHECK (grupo IN (1, 2)),
    unidad_id INT REFERENCES unidad(id) ON DELETE CASCADE,
    sede_id INT REFERENCES sede(id) ON DELETE CASCADE,

    -- Estado del control
    acceso_permitido BOOLEAN NOT NULL DEFAULT TRUE,
    motivo TEXT,  -- "Grupo en descanso", "Suspensión temporal", etc.

    -- Vigencia
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,  -- NULL si es indefinido

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Validación: debe haber al menos un criterio
    CHECK (
        usuario_id IS NOT NULL OR
        grupo IS NOT NULL OR
        unidad_id IS NOT NULL OR
        sede_id IS NOT NULL
    )
);

COMMENT ON TABLE control_acceso_app IS 'Control de acceso a la app móvil por usuario, grupo, unidad o sede';
COMMENT ON COLUMN control_acceso_app.acceso_permitido IS 'True: tiene acceso | False: bloqueado';
COMMENT ON COLUMN control_acceso_app.fecha_fin IS 'NULL si el control es indefinido';

-- Índices
CREATE INDEX idx_control_acceso_usuario ON control_acceso_app(usuario_id) WHERE usuario_id IS NOT NULL;
CREATE INDEX idx_control_acceso_grupo ON control_acceso_app(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX idx_control_acceso_unidad ON control_acceso_app(unidad_id) WHERE unidad_id IS NOT NULL;
CREATE INDEX idx_control_acceso_sede ON control_acceso_app(sede_id) WHERE sede_id IS NOT NULL;
CREATE INDEX idx_control_acceso_vigencia ON control_acceso_app(fecha_inicio, fecha_fin);

-- Trigger para updated_at
CREATE TRIGGER update_control_acceso_updated_at
    BEFORE UPDATE ON control_acceso_app
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- MODIFICAR TABLA ASIGNACION_UNIDAD: Agregar estado de día
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN dia_cerrado BOOLEAN DEFAULT FALSE,
ADD COLUMN fecha_cierre TIMESTAMPTZ,
ADD COLUMN cerrado_por INT REFERENCES usuario(id) ON DELETE SET NULL;

COMMENT ON COLUMN asignacion_unidad.dia_cerrado IS 'True si el día operativo de esta asignación ya fue cerrado';
COMMENT ON COLUMN asignacion_unidad.fecha_cierre IS 'Timestamp de cuándo se cerró el día';
COMMENT ON COLUMN asignacion_unidad.cerrado_por IS 'Usuario que cerró el día (automático o manual)';

CREATE INDEX idx_asignacion_dia_cerrado ON asignacion_unidad(dia_cerrado, turno_id);

-- ========================================
-- VISTAS
-- ========================================

-- Vista: Estado de grupos HOY
CREATE OR REPLACE VIEW v_estado_grupos_hoy AS
SELECT
    grupo,
    estado,
    CASE WHEN estado = 'TRABAJO' THEN TRUE ELSE FALSE END AS esta_de_turno
FROM calendario_grupo
WHERE fecha = CURRENT_DATE;

COMMENT ON VIEW v_estado_grupos_hoy IS 'Estado actual de cada grupo (TRABAJO o DESCANSO)';

-- Vista: Brigadas activas actualmente
CREATE OR REPLACE VIEW v_brigadas_activas_ahora AS
SELECT DISTINCT
    u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    m.turno_id,
    m.destino_asignacion_id AS asignacion_actual,
    m.destino_unidad_id AS unidad_actual,
    un.codigo AS unidad_codigo,
    m.tipo_movimiento,
    m.rol_en_destino,
    m.motivo,
    m.hora_inicio,
    EXTRACT(EPOCH FROM (NOW() - m.hora_inicio)) / 3600 AS horas_en_posicion
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
LEFT JOIN unidad un ON m.destino_unidad_id = un.id
WHERE m.hora_fin IS NULL  -- Movimientos activos
  AND DATE(m.hora_inicio) = CURRENT_DATE
ORDER BY u.nombre_completo;

COMMENT ON VIEW v_brigadas_activas_ahora IS 'Brigadas actualmente en servicio con su ubicación actual';

-- Vista: Historial de movimientos de un brigada
CREATE OR REPLACE VIEW v_historial_movimientos AS
SELECT
    m.id,
    m.usuario_id,
    u.nombre_completo,
    m.turno_id,
    t.fecha AS turno_fecha,
    m.tipo_movimiento,
    -- Origen
    m.origen_unidad_id,
    uo.codigo AS origen_unidad_codigo,
    -- Destino
    m.destino_unidad_id,
    ud.codigo AS destino_unidad_codigo,
    -- Tiempos
    m.hora_inicio,
    m.hora_fin,
    CASE
        WHEN m.hora_fin IS NOT NULL THEN
            EXTRACT(EPOCH FROM (m.hora_fin - m.hora_inicio)) / 3600
        ELSE
            EXTRACT(EPOCH FROM (NOW() - m.hora_inicio)) / 3600
    END AS duracion_horas,
    -- Info adicional
    m.motivo,
    m.rol_en_destino,
    m.created_at
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
LEFT JOIN turno t ON m.turno_id = t.id
LEFT JOIN unidad uo ON m.origen_unidad_id = uo.id
LEFT JOIN unidad ud ON m.destino_unidad_id = ud.id
ORDER BY m.created_at DESC;

COMMENT ON VIEW v_historial_movimientos IS 'Historial completo de movimientos de brigadas';

-- Vista: Composición actual de cada unidad
CREATE OR REPLACE VIEW v_composicion_unidades_ahora AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    json_agg(
        json_build_object(
            'usuario_id', u.id,
            'nombre', u.nombre_completo,
            'rol', m.rol_en_destino,
            'tipo_movimiento', m.tipo_movimiento,
            'desde', m.hora_inicio,
            'motivo', m.motivo
        )
        ORDER BY
            CASE m.rol_en_destino
                WHEN 'PILOTO' THEN 1
                WHEN 'COPILOTO' THEN 2
                WHEN 'ACOMPAÑANTE' THEN 3
                ELSE 4
            END
    ) AS tripulacion_actual,
    COUNT(*) AS total_brigadas
FROM movimiento_brigada m
JOIN usuario u ON m.usuario_id = u.id
JOIN unidad un ON m.destino_unidad_id = un.id
WHERE m.hora_fin IS NULL
  AND DATE(m.hora_inicio) = CURRENT_DATE
GROUP BY un.id, un.codigo
ORDER BY un.codigo;

COMMENT ON VIEW v_composicion_unidades_ahora IS 'Tripulación actual de cada unidad en tiempo real';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Verificar si un usuario puede acceder a la app
CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
    tiene_acceso BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_grupo SMALLINT;
    v_acceso_individual BOOLEAN;
    v_grupo_en_descanso BOOLEAN;
    v_control_activo RECORD;
BEGIN
    -- Obtener datos del usuario
    SELECT grupo, acceso_app_activo
    INTO v_grupo, v_acceso_individual
    FROM usuario
    WHERE id = p_usuario_id;

    -- 1. Verificar acceso individual del usuario
    IF v_acceso_individual = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso individual desactivado';
        RETURN;
    END IF;

    -- 2. Verificar si el grupo está en descanso
    IF v_grupo IS NOT NULL THEN
        SELECT NOT esta_de_turno
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_grupo;

        IF v_grupo_en_descanso THEN
            -- Verificar si hay excepción de acceso para este grupo
            SELECT *
            INTO v_control_activo
            FROM control_acceso_app
            WHERE grupo = v_grupo
              AND acceso_permitido = TRUE
              AND fecha_inicio <= CURRENT_DATE
              AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
            LIMIT 1;

            IF v_control_activo IS NULL THEN
                RETURN QUERY SELECT FALSE, 'Grupo en descanso';
                RETURN;
            END IF;
        END IF;
    END IF;

    -- 3. Verificar controles de acceso específicos
    SELECT *
    INTO v_control_activo
    FROM control_acceso_app
    WHERE usuario_id = p_usuario_id
      AND acceso_permitido = FALSE
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    LIMIT 1;

    IF v_control_activo IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, v_control_activo.motivo;
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION verificar_acceso_app IS 'Verifica si un usuario tiene acceso permitido a la app móvil';

-- Función: Cerrar día operativo automáticamente (ejecutar a las 00:00)
CREATE OR REPLACE FUNCTION cerrar_dia_operativo()
RETURNS TABLE (
    asignaciones_cerradas INT,
    situaciones_migradas INT
) AS $$
DECLARE
    v_asignaciones_cerradas INT := 0;
    v_situaciones_migradas INT := 0;
    v_turno_ayer INT;
    v_turno_hoy INT;
    v_situacion RECORD;
BEGIN
    -- 1. Obtener turnos de ayer y hoy
    SELECT id INTO v_turno_ayer
    FROM turno
    WHERE fecha = CURRENT_DATE - INTERVAL '1 day';

    SELECT id INTO v_turno_hoy
    FROM turno
    WHERE fecha = CURRENT_DATE;

    -- Si no existe turno de hoy, crearlo automáticamente
    IF v_turno_hoy IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (
            CURRENT_DATE,
            'ACTIVO',
            'Turno creado automáticamente por cierre de día',
            1  -- Usuario sistema
        )
        RETURNING id INTO v_turno_hoy;
    END IF;

    -- 2. Cerrar todas las asignaciones del día anterior
    UPDATE asignacion_unidad
    SET
        dia_cerrado = TRUE,
        fecha_cierre = NOW(),
        cerrado_por = 1  -- Usuario sistema
    WHERE turno_id = v_turno_ayer
      AND dia_cerrado = FALSE;

    GET DIAGNOSTICS v_asignaciones_cerradas = ROW_COUNT;

    -- 3. Cerrar todos los movimientos activos del día anterior
    UPDATE movimiento_brigada
    SET hora_fin = NOW()
    WHERE turno_id = v_turno_ayer
      AND hora_fin IS NULL;

    -- 4. Migrar situaciones activas al nuevo día
    FOR v_situacion IN
        SELECT *
        FROM situacion
        WHERE turno_id = v_turno_ayer
          AND estado = 'ACTIVA'
    LOOP
        -- Actualizar turno de la situación
        UPDATE situacion
        SET turno_id = v_turno_hoy
        WHERE id = v_situacion.id;

        v_situaciones_migradas := v_situaciones_migradas + 1;
    END LOOP;

    RETURN QUERY SELECT v_asignaciones_cerradas, v_situaciones_migradas;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_dia_operativo IS 'Cierra el día operativo a las 00:00: cierra asignaciones, movimientos y migra situaciones activas';

-- Función: Generar calendario de grupos automáticamente
CREATE OR REPLACE FUNCTION generar_calendario_grupos(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS INT AS $$
DECLARE
    v_fecha DATE;
    v_dias_transcurridos INT;
    v_estado_grupo1 VARCHAR(20);
    v_estado_grupo2 VARCHAR(20);
    v_registros_creados INT := 0;
BEGIN
    v_fecha := p_fecha_inicio;

    WHILE v_fecha <= p_fecha_fin LOOP
        -- Calcular días desde una fecha base (ej: 1 de enero de 2025)
        v_dias_transcurridos := v_fecha - DATE '2025-01-01';

        -- Ciclo de 16 días: 8 trabajo, 8 descanso
        -- Si días_transcurridos mod 16 está entre 0-7: Grupo 1 trabaja
        -- Si días_transcurridos mod 16 está entre 8-15: Grupo 2 trabaja

        IF MOD(v_dias_transcurridos, 16) < 8 THEN
            v_estado_grupo1 := 'TRABAJO';
            v_estado_grupo2 := 'DESCANSO';
        ELSE
            v_estado_grupo1 := 'DESCANSO';
            v_estado_grupo2 := 'TRABAJO';
        END IF;

        -- Insertar para Grupo 1
        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (1, v_fecha, v_estado_grupo1, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        -- Insertar para Grupo 2
        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (2, v_fecha, v_estado_grupo2, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        v_registros_creados := v_registros_creados + 2;
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    RETURN v_registros_creados;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generar_calendario_grupos IS 'Genera calendario de trabajo/descanso para ambos grupos en un rango de fechas';

-- ========================================
-- DATOS INICIALES
-- ========================================

-- Generar calendario para los próximos 90 días
SELECT generar_calendario_grupos(CURRENT_DATE, CURRENT_DATE + INTERVAL '90 days');
