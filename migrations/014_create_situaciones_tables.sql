-- Migración 014: Sistema de situaciones operativas y bitácora

-- ========================================
-- TABLA: SITUACION
-- ========================================

CREATE TABLE situacion (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    numero_situacion VARCHAR(50) UNIQUE,  -- "SIT-2025-0001"

    -- Clasificación
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

    -- Asignación
    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,
    turno_id INT REFERENCES turno(id) ON DELETE CASCADE,

    -- Ubicación
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    ubicacion_manual BOOLEAN DEFAULT FALSE,  -- True si fue ingresada manualmente (demo)

    -- Datos operativos
    combustible DECIMAL(5,2),  -- Litros
    kilometraje_unidad DECIMAL(8,1),  -- Kilometraje del odómetro

    -- Tripulación confirmada (JSON)
    tripulacion_confirmada JSONB,
    -- Ejemplo: [{ "usuario_id": 1, "nombre": "Juan Pérez", "rol": "PILOTO", "presente": true }]

    -- Observaciones
    descripcion TEXT,  -- Descripción breve de la situación
    observaciones TEXT,  -- Observaciones adicionales

    -- Relación con incidente (si la situación es un incidente)
    incidente_id INT REFERENCES incidente(id) ON DELETE SET NULL,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    actualizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE situacion IS 'Situaciones operativas de unidades (salidas, patrullajes, incidentes, etc.)';
COMMENT ON COLUMN situacion.tipo_situacion IS 'Tipo de situación operativa reportada';
COMMENT ON COLUMN situacion.estado IS 'ACTIVA: en curso | CERRADA: finalizada | CANCELADA: cancelada';
COMMENT ON COLUMN situacion.ubicacion_manual IS 'True si la ubicación fue ingresada manualmente (modo demo)';
COMMENT ON COLUMN situacion.tripulacion_confirmada IS 'Tripulación confirmada al momento de crear la situación (JSON array)';

-- Índices
CREATE INDEX idx_situacion_unidad ON situacion(unidad_id);
CREATE INDEX idx_situacion_turno ON situacion(turno_id);
CREATE INDEX idx_situacion_asignacion ON situacion(asignacion_id);
CREATE INDEX idx_situacion_tipo ON situacion(tipo_situacion);
CREATE INDEX idx_situacion_estado ON situacion(estado);
CREATE INDEX idx_situacion_created ON situacion(created_at DESC);
CREATE INDEX idx_situacion_incidente ON situacion(incidente_id) WHERE incidente_id IS NOT NULL;
CREATE INDEX idx_situacion_ubicacion ON situacion USING GIST (ll_to_earth(latitud, longitud))
    WHERE latitud IS NOT NULL AND longitud IS NOT NULL;

-- Trigger para updated_at
CREATE TRIGGER update_situacion_updated_at
    BEFORE UPDATE ON situacion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: DETALLE_SITUACION
-- ========================================

CREATE TABLE detalle_situacion (
    id BIGSERIAL PRIMARY KEY,
    situacion_id BIGINT NOT NULL REFERENCES situacion(id) ON DELETE CASCADE,

    -- Tipo de detalle
    tipo_detalle VARCHAR(50) NOT NULL CHECK (tipo_detalle IN (
        'VEHICULO',
        'AUTORIDAD',
        'RECURSO',
        'VICTIMA',
        'GRUA',
        'ASEGURADORA',
        'TESTIGO',
        'EVIDENCIA',
        'OBSTRUCCION',
        'OTROS'
    )),

    -- Datos flexibles en JSON
    datos JSONB NOT NULL,

    -- Ejemplos de estructura de datos por tipo:
    /*
    VEHICULO: {
        "placa": "P123ABC",
        "marca": "Toyota",
        "modelo": "Corolla",
        "color": "Rojo",
        "anio": 2020,
        "tarjeta_circulacion": "TC123456",
        "piloto": {
            "nombre": "Juan Pérez",
            "licencia": "A123456",
            "telefono": "12345678",
            "estado": "ILESO"
        },
        "danos": "MODERADO",
        "observaciones": "Daños en la parte frontal"
    }

    AUTORIDAD: {
        "institucion": "PNC",
        "nombre_oficial": "Agente José López",
        "placa_oficial": "PNC-001",
        "hora_llegada": "10:30",
        "hora_salida": "12:00",
        "observaciones": "Levantó acta"
    }

    RECURSO: {
        "tipo": "AMBULANCIA",
        "proveedor": "Bomberos Voluntarios",
        "hora_solicitud": "10:15",
        "hora_llegada": "10:35",
        "observaciones": "Trasladó 2 heridos"
    }

    VICTIMA: {
        "nombre": "María González",
        "edad": 35,
        "genero": "F",
        "condicion": "HERIDO_LEVE",
        "hospital_destino": "Hospital Roosevelt",
        "observaciones": "Golpe en la cabeza"
    }

    GRUA: {
        "empresa": "Grúas Provial",
        "placa_grua": "G123ABC",
        "conductor": "Pedro Ramírez",
        "destino_vehiculo": "Taller Central",
        "hora_llegada": "11:00"
    }

    ASEGURADORA: {
        "nombre": "Seguros G&T",
        "ajustador": "Carlos Méndez",
        "telefono": "12345678",
        "hora_llegada": "11:30",
        "observaciones": "Evaluó daños"
    }
    */

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE detalle_situacion IS 'Detalles específicos de situaciones (vehículos, autoridades, recursos, etc.)';
COMMENT ON COLUMN detalle_situacion.tipo_detalle IS 'Tipo de detalle asociado a la situación';
COMMENT ON COLUMN detalle_situacion.datos IS 'Datos flexibles en JSON según el tipo de detalle';

-- Índices
CREATE INDEX idx_detalle_situacion ON detalle_situacion(situacion_id);
CREATE INDEX idx_detalle_tipo ON detalle_situacion(tipo_detalle);
CREATE INDEX idx_detalle_created ON detalle_situacion(created_at DESC);

-- Trigger para updated_at
CREATE TRIGGER update_detalle_situacion_updated_at
    BEFORE UPDATE ON detalle_situacion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- VISTA: V_SITUACIONES_COMPLETAS
-- ========================================

CREATE OR REPLACE VIEW v_situaciones_completas AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,

    -- Ubicación
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,

    -- Datos operativos
    s.combustible,
    s.kilometraje_unidad,
    s.descripcion,
    s.observaciones,
    s.tripulacion_confirmada,

    -- Unidad
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Turno y asignación
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,

    -- Incidente relacionado
    s.incidente_id,
    i.numero_reporte AS incidente_numero,

    -- Auditoría
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.actualizado_por,
    ua.nombre_completo AS actualizado_por_nombre,
    s.created_at,
    s.updated_at,

    -- Detalles agregados (JSON array)
    (
        SELECT json_agg(
            json_build_object(
                'id', d.id,
                'tipo_detalle', d.tipo_detalle,
                'datos', d.datos,
                'created_at', d.created_at
            )
            ORDER BY d.created_at ASC
        )
        FROM detalle_situacion d
        WHERE d.situacion_id = s.id
    ) AS detalles

FROM situacion s
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN turno t ON s.turno_id = t.id
LEFT JOIN incidente i ON s.incidente_id = i.id
LEFT JOIN usuario uc ON s.creado_por = uc.id
LEFT JOIN usuario ua ON s.actualizado_por = ua.id
ORDER BY s.created_at DESC;

COMMENT ON VIEW v_situaciones_completas IS 'Vista completa de situaciones con todos los datos relacionados y detalles';

-- ========================================
-- VISTA: V_ULTIMA_SITUACION_UNIDAD
-- ========================================

CREATE OR REPLACE VIEW v_ultima_situacion_unidad AS
SELECT DISTINCT ON (s.unidad_id)
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS situacion_id,
    s.uuid AS situacion_uuid,
    s.tipo_situacion,
    s.estado,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.descripcion,
    s.created_at AS situacion_fecha,
    s.turno_id,
    t.fecha AS turno_fecha

FROM situacion s
JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.estado = 'ACTIVA'
ORDER BY s.unidad_id, s.created_at DESC;

COMMENT ON VIEW v_ultima_situacion_unidad IS 'Última situación activa por unidad (para mapa en tiempo real)';

-- ========================================
-- VISTA: V_BITACORA_UNIDAD
-- ========================================

CREATE OR REPLACE VIEW v_bitacora_unidad AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.tipo_situacion,
    s.estado,
    s.ruta_codigo,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.descripcion,
    s.observaciones,
    s.created_at AS fecha_hora,
    s.creado_por_nombre AS reportado_por,
    s.turno_fecha,

    -- Duración (si está cerrada)
    CASE
        WHEN s.estado = 'CERRADA' THEN
            EXTRACT(EPOCH FROM (s.updated_at - s.created_at)) / 60  -- minutos
        ELSE NULL
    END AS duracion_minutos,

    -- Tiene detalles
    CASE WHEN s.detalles IS NOT NULL THEN TRUE ELSE FALSE END AS tiene_detalles,

    -- Cantidad de detalles por tipo
    (
        SELECT json_object_agg(tipo_detalle, cantidad)
        FROM (
            SELECT
                d.tipo_detalle,
                COUNT(*) AS cantidad
            FROM detalle_situacion d
            WHERE d.situacion_id = s.id
            GROUP BY d.tipo_detalle
        ) AS detalles_count
    ) AS resumen_detalles

FROM v_situaciones_completas s
JOIN unidad u ON s.unidad_id = u.id
ORDER BY s.unidad_id, s.created_at DESC;

COMMENT ON VIEW v_bitacora_unidad IS 'Bitácora completa de situaciones por unidad (para historial)';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Generar número de situación automático
CREATE OR REPLACE FUNCTION generar_numero_situacion()
RETURNS TRIGGER AS $$
DECLARE
    anio INT;
    numero_secuencial INT;
    numero_final VARCHAR(50);
BEGIN
    -- Obtener año actual
    anio := EXTRACT(YEAR FROM NOW());

    -- Obtener el siguiente número secuencial del año
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(numero_situacion FROM 'SIT-[0-9]{4}-([0-9]+)')
            AS INT
        )
    ), 0) + 1
    INTO numero_secuencial
    FROM situacion
    WHERE numero_situacion LIKE 'SIT-' || anio || '-%';

    -- Generar número final con padding
    numero_final := 'SIT-' || anio || '-' || LPAD(numero_secuencial::TEXT, 4, '0');

    NEW.numero_situacion := numero_final;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generar_numero_situacion
    BEFORE INSERT ON situacion
    FOR EACH ROW
    WHEN (NEW.numero_situacion IS NULL)
    EXECUTE FUNCTION generar_numero_situacion();

COMMENT ON FUNCTION generar_numero_situacion IS 'Genera automáticamente el número de situación (SIT-YYYY-NNNN)';

-- Función: Cerrar situaciones antiguas automáticamente
CREATE OR REPLACE FUNCTION cerrar_situaciones_antiguas(horas_limite INT DEFAULT 24)
RETURNS INT AS $$
DECLARE
    cantidad_cerradas INT;
BEGIN
    WITH cerradas AS (
        UPDATE situacion
        SET
            estado = 'CERRADA',
            actualizado_por = creado_por,
            updated_at = NOW()
        WHERE estado = 'ACTIVA'
          AND created_at < NOW() - (horas_limite || ' hours')::INTERVAL
        RETURNING id
    )
    SELECT COUNT(*) INTO cantidad_cerradas FROM cerradas;

    RETURN cantidad_cerradas;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_situaciones_antiguas IS 'Cierra automáticamente situaciones activas de más de X horas (default 24)';

-- ========================================
-- DATOS SEED
-- ========================================

-- (Los datos de ejemplo se agregarán después con las unidades y turnos existentes)
