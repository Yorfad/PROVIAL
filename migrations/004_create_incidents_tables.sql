-- Migración 004: Tablas de incidentes (CORE)

-- ========================================
-- TABLA PRINCIPAL: INCIDENTE
-- ========================================

CREATE TABLE incidente (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
    numero_reporte VARCHAR(50) UNIQUE,

    -- Clasificación y origen
    origen VARCHAR(30) NOT NULL CHECK (origen IN ('BRIGADA', 'USUARIO_PUBLICO', 'CENTRO_CONTROL')),
    estado VARCHAR(30) NOT NULL DEFAULT 'REPORTADO'
        CHECK (estado IN ('REPORTADO', 'EN_ATENCION', 'REGULACION', 'CERRADO', 'NO_ATENDIDO')),

    -- Tipo de hecho
    tipo_hecho_id INT NOT NULL REFERENCES tipo_hecho(id) ON DELETE RESTRICT,
    subtipo_hecho_id INT REFERENCES subtipo_hecho(id) ON DELETE SET NULL,

    -- Ubicación
    ruta_id INT NOT NULL REFERENCES ruta(id) ON DELETE RESTRICT,
    km DECIMAL(6,2) NOT NULL,
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),
    referencia_ubicacion TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Asignación
    unidad_id INT REFERENCES unidad(id) ON DELETE SET NULL,
    brigada_id INT REFERENCES brigada(id) ON DELETE SET NULL,

    -- Tiempos (cronología del incidente)
    fecha_hora_aviso TIMESTAMPTZ NOT NULL,
    fecha_hora_asignacion TIMESTAMPTZ,
    fecha_hora_llegada TIMESTAMPTZ,
    fecha_hora_estabilizacion TIMESTAMPTZ,
    fecha_hora_finalizacion TIMESTAMPTZ,

    -- Víctimas
    hay_heridos BOOLEAN NOT NULL DEFAULT FALSE,
    cantidad_heridos INT NOT NULL DEFAULT 0,
    hay_fallecidos BOOLEAN NOT NULL DEFAULT FALSE,
    cantidad_fallecidos INT NOT NULL DEFAULT 0,

    -- Recursos solicitados
    requiere_bomberos BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_pnc BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_ambulancia BOOLEAN NOT NULL DEFAULT FALSE,

    -- Observaciones
    observaciones_iniciales TEXT,
    observaciones_finales TEXT,

    -- Campos para accidentología
    condiciones_climaticas VARCHAR(50),
    tipo_pavimento VARCHAR(50),
    iluminacion VARCHAR(50),
    senalizacion VARCHAR(50),
    visibilidad VARCHAR(50),
    causa_probable TEXT,

    -- Información del reportante (si es público)
    reportado_por_nombre VARCHAR(150),
    reportado_por_telefono VARCHAR(20),
    reportado_por_email VARCHAR(100),
    foto_url TEXT,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT chk_heridos CHECK (
        (hay_heridos = FALSE AND cantidad_heridos = 0) OR
        (hay_heridos = TRUE AND cantidad_heridos > 0)
    ),
    CONSTRAINT chk_fallecidos CHECK (
        (hay_fallecidos = FALSE AND cantidad_fallecidos = 0) OR
        (hay_fallecidos = TRUE AND cantidad_fallecidos > 0)
    ),
    CONSTRAINT chk_fechas_cronologicas CHECK (
        (fecha_hora_llegada IS NULL OR fecha_hora_llegada >= fecha_hora_aviso) AND
        (fecha_hora_finalizacion IS NULL OR fecha_hora_finalizacion >= fecha_hora_aviso)
    )
);

COMMENT ON TABLE incidente IS 'Tabla principal de incidentes/hechos viales';
COMMENT ON COLUMN incidente.numero_reporte IS 'Número único legible (ej: INC-2025-0001)';
COMMENT ON COLUMN incidente.origen IS 'Quién reportó el incidente';
COMMENT ON COLUMN incidente.estado IS 'Estado actual del incidente';

-- Índices críticos para performance
CREATE INDEX idx_incidente_uuid ON incidente(uuid);
CREATE INDEX idx_incidente_numero ON incidente(numero_reporte);
CREATE INDEX idx_incidente_estado ON incidente(estado);
CREATE INDEX idx_incidente_origen ON incidente(origen);
CREATE INDEX idx_incidente_fecha_aviso ON incidente(fecha_hora_aviso);
CREATE INDEX idx_incidente_ruta_km ON incidente(ruta_id, km);
CREATE INDEX idx_incidente_unidad ON incidente(unidad_id);
CREATE INDEX idx_incidente_created_at ON incidente(created_at DESC);
CREATE INDEX idx_incidente_tipo_hecho ON incidente(tipo_hecho_id);

-- Índice para búsquedas de incidentes activos/recientes
CREATE INDEX idx_incidente_activos ON incidente(fecha_hora_aviso, estado)
WHERE estado IN ('REPORTADO', 'EN_ATENCION', 'REGULACION');

-- ========================================
-- TABLA: VEHICULO INCIDENTE
-- ========================================

CREATE TABLE vehiculo_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,

    -- Datos del vehículo
    tipo_vehiculo_id INT REFERENCES tipo_vehiculo(id) ON DELETE SET NULL,
    marca_id INT REFERENCES marca_vehiculo(id) ON DELETE SET NULL,
    modelo VARCHAR(50),
    anio INT,
    color VARCHAR(30),
    placa VARCHAR(20),

    -- Piloto
    estado_piloto VARCHAR(30) CHECK (estado_piloto IN ('ILESO', 'HERIDO', 'FALLECIDO', 'TRASLADADO', 'HUYO')),
    nombre_piloto VARCHAR(150),
    licencia_piloto VARCHAR(50),

    -- Víctimas en este vehículo
    heridos_en_vehiculo INT NOT NULL DEFAULT 0,
    fallecidos_en_vehiculo INT NOT NULL DEFAULT 0,

    -- Daños
    danos_estimados VARCHAR(50) CHECK (danos_estimados IN ('LEVE', 'MODERADO', 'GRAVE', 'PERDIDA_TOTAL')),
    observaciones TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE vehiculo_incidente IS 'Vehículos involucrados en un incidente';

CREATE INDEX idx_vehiculo_incidente ON vehiculo_incidente(incidente_id);
CREATE INDEX idx_vehiculo_tipo ON vehiculo_incidente(tipo_vehiculo_id);

-- ========================================
-- TABLA: OBSTRUCCION INCIDENTE
-- ========================================

CREATE TABLE obstruccion_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    descripcion_generada TEXT,
    datos_carriles_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE obstruccion_incidente IS 'Información de obstrucción de carriles (relación 1:1 con incidente)';
COMMENT ON COLUMN obstruccion_incidente.descripcion_generada IS 'Texto auto-generado legible de la obstrucción';
COMMENT ON COLUMN obstruccion_incidente.datos_carriles_json IS 'Estado detallado de carriles por dirección';

CREATE INDEX idx_obstruccion_incidente ON obstruccion_incidente(incidente_id);

-- ========================================
-- TABLA: RECURSO INCIDENTE
-- ========================================

CREATE TABLE recurso_incidente (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL REFERENCES incidente(id) ON DELETE CASCADE,
    tipo_recurso VARCHAR(50) NOT NULL CHECK (tipo_recurso IN ('GRUA', 'BOMBEROS', 'PNC', 'AMBULANCIA', 'AJUSTADOR', 'OTRO')),
    descripcion TEXT,
    hora_solicitud TIMESTAMPTZ,
    hora_llegada TIMESTAMPTZ,
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE recurso_incidente IS 'Recursos externos solicitados para un incidente';

CREATE INDEX idx_recurso_incidente ON recurso_incidente(incidente_id);

-- ========================================
-- TABLA: INCIDENTE NO ATENDIDO
-- ========================================

CREATE TABLE incidente_no_atendido (
    id BIGSERIAL PRIMARY KEY,
    incidente_id BIGINT NOT NULL UNIQUE REFERENCES incidente(id) ON DELETE CASCADE,
    motivo_id INT NOT NULL REFERENCES motivo_no_atendido(id) ON DELETE RESTRICT,
    observaciones TEXT,
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE incidente_no_atendido IS 'Información de incidentes que no fueron atendidos (relación 1:1)';

CREATE INDEX idx_incidente_no_atendido ON incidente_no_atendido(incidente_id);
CREATE INDEX idx_incidente_no_atendido_motivo ON incidente_no_atendido(motivo_id);
