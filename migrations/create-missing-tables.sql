-- Script para crear tablas faltantes SIN dependencias de PostGIS

-- ========================================
-- 1. TABLA: SITUACION (sin índice PostGIS)
-- ========================================

CREATE TABLE IF NOT EXISTS situacion (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    numero_situacion VARCHAR(50) UNIQUE,

    tipo_situacion VARCHAR(50) NOT NULL CHECK (tipo_situacion IN (
        'SALIDA_SEDE',
        'PATRULLAJE',
        'CAMBIO_RUTA',
        'PARADA_ESTRATEGICA',
        'COMIDA',
        'DESCANSO',
        'INCIDENTE',
        'REGULACION_TRAFICO',
        'ASISTENCIA_VEHICULAR',
        'OTROS'
    )),
    estado VARCHAR(20) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'CERRADA', 'CANCELADA')),

    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    ubicacion_manual BOOLEAN DEFAULT FALSE,

    combustible DECIMAL(5,2),
    kilometraje_unidad DECIMAL(8,1),

    tripulacion_confirmada JSONB,

    descripcion TEXT,
    observaciones TEXT,

    incidente_id INT REFERENCES incidente(id) ON DELETE SET NULL,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices (sin PostGIS)
CREATE INDEX IF NOT EXISTS idx_situacion_unidad ON situacion(unidad_id);
CREATE INDEX IF NOT EXISTS idx_situacion_turno ON situacion(turno_id);
CREATE INDEX IF NOT EXISTS idx_situacion_asignacion ON situacion(asignacion_id);
CREATE INDEX IF NOT EXISTS idx_situacion_tipo ON situacion(tipo_situacion);
CREATE INDEX IF NOT EXISTS idx_situacion_estado ON situacion(estado);
CREATE INDEX IF NOT EXISTS idx_situacion_created ON situacion(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_situacion_incidente ON situacion(incidente_id) WHERE incidente_id IS NOT NULL;

-- Trigger para updated_at
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'update_situacion_updated_at'
    ) THEN
        CREATE TRIGGER update_situacion_updated_at
            BEFORE UPDATE ON situacion
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- ========================================
-- 2. TABLA: DETALLE_SITUACION
-- ========================================

CREATE TABLE IF NOT EXISTS detalle_situacion (
    id BIGSERIAL PRIMARY KEY,
    situacion_id BIGINT NOT NULL REFERENCES situacion(id) ON DELETE CASCADE,

    tipo_detalle VARCHAR(50) NOT NULL CHECK (tipo_detalle IN (
        'VEHICULO',
        'AUTORIDAD',
        'RECURSO',
        'VICTIMA',
        'GRUA',
        'ASEGURADORA',
        'OTRO'
    )),

    datos JSONB NOT NULL,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_detalle_situacion ON detalle_situacion(situacion_id);
CREATE INDEX IF NOT EXISTS idx_detalle_tipo ON detalle_situacion(tipo_detalle);

-- ========================================
-- 3. AGREGAR COLUMNAS A USUARIO (si no existen)
-- ========================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'grupo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2));
        CREATE INDEX idx_usuario_grupo ON usuario(grupo) WHERE grupo IS NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'fecha_inicio_ciclo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN fecha_inicio_ciclo DATE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'acceso_app_activo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;
        CREATE INDEX idx_usuario_acceso ON usuario(acceso_app_activo);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'exento_grupos'
    ) THEN
        ALTER TABLE usuario ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ========================================
-- 4. TABLA: CALENDARIO_GRUPO
-- ========================================

CREATE TABLE IF NOT EXISTS calendario_grupo (
    id SERIAL PRIMARY KEY,
    grupo SMALLINT NOT NULL CHECK (grupo IN (1, 2)),
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('TRABAJO', 'DESCANSO')),
    observaciones TEXT,

    creado_por INT REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(grupo, fecha)
);

CREATE INDEX IF NOT EXISTS idx_calendario_grupo_fecha ON calendario_grupo(grupo, fecha DESC);
CREATE INDEX IF NOT EXISTS idx_calendario_grupo_estado ON calendario_grupo(estado, fecha);

-- ========================================
-- 5. TABLA: CONTROL_ACCESO_APP
-- ========================================

CREATE TABLE IF NOT EXISTS control_acceso_app (
    id SERIAL PRIMARY KEY,

    usuario_id INT REFERENCES usuario(id) ON DELETE CASCADE,
    grupo SMALLINT CHECK (grupo IN (1, 2)),
    unidad_id INT REFERENCES unidad(id) ON DELETE CASCADE,
    sede_id INT REFERENCES sede(id) ON DELETE CASCADE,

    acceso_permitido BOOLEAN NOT NULL DEFAULT TRUE,
    motivo TEXT,

    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,

    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CHECK (
        usuario_id IS NOT NULL OR
        grupo IS NOT NULL OR
        unidad_id IS NOT NULL OR
        sede_id IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_control_acceso_usuario ON control_acceso_app(usuario_id) WHERE usuario_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_control_acceso_grupo ON control_acceso_app(grupo) WHERE grupo IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_control_acceso_vigencia ON control_acceso_app(fecha_inicio, fecha_fin);

-- ========================================
-- 6. VISTAS
-- ========================================

-- Vista: Estado de grupos HOY
CREATE OR REPLACE VIEW v_estado_grupos_hoy AS
SELECT
    grupo,
    estado,
    CASE WHEN estado = 'TRABAJO' THEN TRUE ELSE FALSE END AS esta_de_turno
FROM calendario_grupo
WHERE fecha = CURRENT_DATE;

-- Vista: Situaciones completas
CREATE OR REPLACE VIEW v_situaciones_completas AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,
    s.combustible,
    s.kilometraje_unidad,
    s.tripulacion_confirmada,
    s.descripcion,
    s.observaciones,
    s.incidente_id,
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.created_at,
    s.updated_at
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
LEFT JOIN usuario uc ON s.creado_por = uc.id;

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Verificar acceso a la app
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
    SELECT grupo, COALESCE(acceso_app_activo, TRUE)
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
        SELECT NOT COALESCE(esta_de_turno, TRUE)
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_grupo;

        IF v_grupo_en_descanso THEN
            RETURN QUERY SELECT FALSE, 'Grupo en descanso';
            RETURN;
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

-- Función: Generar calendario de grupos
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
        v_dias_transcurridos := v_fecha - DATE '2025-01-01';

        IF MOD(v_dias_transcurridos, 16) < 8 THEN
            v_estado_grupo1 := 'TRABAJO';
            v_estado_grupo2 := 'DESCANSO';
        ELSE
            v_estado_grupo1 := 'DESCANSO';
            v_estado_grupo2 := 'TRABAJO';
        END IF;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (1, v_fecha, v_estado_grupo1, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (2, v_fecha, v_estado_grupo2, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        v_registros_creados := v_registros_creados + 2;
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    RETURN v_registros_creados;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 8. GENERAR CALENDARIO DE GRUPOS
-- ========================================

SELECT generar_calendario_grupos((CURRENT_DATE - INTERVAL '30 days')::DATE, (CURRENT_DATE + INTERVAL '90 days')::DATE);
