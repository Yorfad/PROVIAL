-- Migración 005: Tablas de actividades de unidades

-- ========================================
-- TABLA: ACTIVIDAD UNIDAD
-- ========================================

CREATE TABLE actividad_unidad (
    id BIGSERIAL PRIMARY KEY,

    -- Unidad y tipo
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE CASCADE,
    tipo_actividad_id INT NOT NULL REFERENCES tipo_actividad(id) ON DELETE RESTRICT,

    -- Asociación opcional a incidente
    incidente_id BIGINT REFERENCES incidente(id) ON DELETE SET NULL,

    -- Ubicación
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),

    -- Tiempos
    hora_inicio TIMESTAMPTZ NOT NULL,
    hora_fin TIMESTAMPTZ,

    -- Detalles
    observaciones TEXT,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraint
    CONSTRAINT chk_actividad_tiempos CHECK (
        hora_fin IS NULL OR hora_fin >= hora_inicio
    )
);

COMMENT ON TABLE actividad_unidad IS 'Actividades que realizan las unidades durante el día';
COMMENT ON COLUMN actividad_unidad.hora_fin IS 'NULL si la actividad está en curso';

-- Índices
CREATE INDEX idx_actividad_unidad ON actividad_unidad(unidad_id);
CREATE INDEX idx_actividad_fecha ON actividad_unidad(hora_inicio DESC);
CREATE INDEX idx_actividad_tipo ON actividad_unidad(tipo_actividad_id);
CREATE INDEX idx_actividad_incidente ON actividad_unidad(incidente_id);

-- Índice para actividades activas (hora_fin NULL)
CREATE INDEX idx_actividad_activa ON actividad_unidad(unidad_id, hora_fin)
WHERE hora_fin IS NULL;

-- Constraint: Una unidad solo puede tener UNA actividad activa (hora_fin NULL) a la vez
CREATE UNIQUE INDEX idx_unidad_actividad_activa
ON actividad_unidad (unidad_id)
WHERE hora_fin IS NULL;

COMMENT ON INDEX idx_unidad_actividad_activa IS 'Garantiza que una unidad solo tenga una actividad activa simultáneamente';
