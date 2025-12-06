-- Migración 010: Sistema de turnos y asignaciones de operaciones

-- ========================================
-- TABLA: TURNO
-- ========================================

CREATE TABLE turno (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'PLANIFICADO'
        CHECK (estado IN ('PLANIFICADO', 'ACTIVO', 'CERRADO')),

    -- Observaciones generales del día
    observaciones TEXT,

    -- Auditoría
    creado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    aprobado_por INT REFERENCES usuario(id) ON DELETE SET NULL,
    fecha_aprobacion TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un solo turno por fecha
    UNIQUE(fecha)
);

COMMENT ON TABLE turno IS 'Turnos de trabajo por día (planificación de Operaciones)';
COMMENT ON COLUMN turno.estado IS 'PLANIFICADO: creado pero no iniciado | ACTIVO: en curso | CERRADO: finalizado';

CREATE INDEX idx_turno_fecha ON turno(fecha DESC);
CREATE INDEX idx_turno_estado ON turno(estado);

-- Trigger para updated_at
CREATE TRIGGER update_turno_updated_at
    BEFORE UPDATE ON turno
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: ASIGNACION_UNIDAD
-- ========================================

CREATE TABLE asignacion_unidad (
    id SERIAL PRIMARY KEY,
    turno_id INT NOT NULL REFERENCES turno(id) ON DELETE CASCADE,
    unidad_id INT NOT NULL REFERENCES unidad(id) ON DELETE RESTRICT,

    -- Zona de patrullaje asignada
    ruta_id INT REFERENCES ruta(id) ON DELETE SET NULL,
    km_inicio DECIMAL(6,2),
    km_final DECIMAL(6,2),
    sentido VARCHAR(30) CHECK (sentido IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE', 'AMBOS')),

    -- Acciones/instrucciones específicas
    acciones TEXT,
    -- Ejemplos:
    --  "Regular en km 30"
    --  "Apoyo a trabajos en km 10"
    --  "Patrullaje rutinario"

    -- Control de combustible
    combustible_inicial DECIMAL(5,2), -- Litros al inicio
    combustible_asignado DECIMAL(5,2), -- Litros asignados para el turno

    -- Horario
    hora_salida TIME,
    hora_entrada_estimada TIME,

    -- Estado real (se actualiza durante el día)
    hora_salida_real TIMESTAMPTZ,
    hora_entrada_real TIMESTAMPTZ,
    combustible_final DECIMAL(5,2), -- Litros al finalizar
    km_recorridos DECIMAL(8,2), -- Calculado automáticamente

    observaciones_finales TEXT, -- Al cerrar el turno

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Una unidad solo puede tener una asignación por turno
    UNIQUE(turno_id, unidad_id)
);

COMMENT ON TABLE asignacion_unidad IS 'Asignación de unidades a rutas/zonas por turno';
COMMENT ON COLUMN asignacion_unidad.acciones IS 'Instrucciones específicas para la unidad en este turno';
COMMENT ON COLUMN asignacion_unidad.km_recorridos IS 'Kilometraje recorrido durante el turno';

CREATE INDEX idx_asignacion_turno ON asignacion_unidad(turno_id);
CREATE INDEX idx_asignacion_unidad ON asignacion_unidad(unidad_id);
CREATE INDEX idx_asignacion_ruta ON asignacion_unidad(ruta_id);

-- Trigger para updated_at
CREATE TRIGGER update_asignacion_updated_at
    BEFORE UPDATE ON asignacion_unidad
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- TABLA: TRIPULACION_TURNO
-- ========================================

CREATE TABLE tripulacion_turno (
    id SERIAL PRIMARY KEY,
    asignacion_id INT NOT NULL REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
    usuario_id INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,

    -- Rol en la unidad
    rol_tripulacion VARCHAR(30) NOT NULL CHECK (rol_tripulacion IN ('PILOTO', 'COPILOTO', 'ACOMPAÑANTE')),

    -- Control de asistencia
    presente BOOLEAN DEFAULT TRUE,
    observaciones TEXT, -- Si no vino, motivo, etc.

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un usuario solo puede tener un rol por asignación
    UNIQUE(asignacion_id, usuario_id)
);

COMMENT ON TABLE tripulacion_turno IS 'Tripulación asignada a cada unidad por turno';
COMMENT ON COLUMN tripulacion_turno.rol_tripulacion IS 'Rol del brigadista en la unidad para este turno';
COMMENT ON COLUMN tripulacion_turno.presente IS 'Si el brigadista se presentó al turno';

CREATE INDEX idx_tripulacion_asignacion ON tripulacion_turno(asignacion_id);
CREATE INDEX idx_tripulacion_usuario ON tripulacion_turno(usuario_id);

-- Constraint: Solo un piloto por unidad
CREATE UNIQUE INDEX idx_un_piloto_por_asignacion
ON tripulacion_turno (asignacion_id)
WHERE rol_tripulacion = 'PILOTO';

COMMENT ON INDEX idx_un_piloto_por_asignacion IS 'Garantiza que cada unidad tenga exactamente un piloto';

-- ========================================
-- TABLA: REPORTE_HORARIO
-- ========================================

CREATE TABLE reporte_horario (
    id BIGSERIAL PRIMARY KEY,
    asignacion_id INT NOT NULL REFERENCES asignacion_unidad(id) ON DELETE CASCADE,

    -- Ubicación actual
    km_actual DECIMAL(6,2) NOT NULL,
    sentido_actual VARCHAR(30) CHECK (sentido_actual IN ('NORTE', 'SUR', 'ESTE', 'OESTE', 'ASCENDENTE', 'DESCENDENTE')),
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Novedades
    novedad TEXT, -- "Sin novedad" | "Tráfico lento" | "Regulando en km X" | etc.

    -- Metadata
    reportado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reporte_horario IS 'Reportes horarios de posición de unidades (para COP y secuencia de radio)';

CREATE INDEX idx_reporte_asignacion ON reporte_horario(asignacion_id);
CREATE INDEX idx_reporte_created ON reporte_horario(created_at DESC);

-- ========================================
-- MODIFICAR TABLA INCIDENTE
-- ========================================

-- Agregar relación con asignación (opcional, para trazabilidad)
ALTER TABLE incidente
ADD COLUMN asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL;

CREATE INDEX idx_incidente_asignacion ON incidente(asignacion_id);

COMMENT ON COLUMN incidente.asignacion_id IS 'Asignación de la unidad que atendió (si aplica)';

-- ========================================
-- MODIFICAR TABLA ACTIVIDAD_UNIDAD
-- ========================================

-- Agregar relación con asignación
ALTER TABLE actividad_unidad
ADD COLUMN asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL;

CREATE INDEX idx_actividad_asignacion ON actividad_unidad(asignacion_id);

COMMENT ON COLUMN actividad_unidad.asignacion_id IS 'Asignación durante la cual se realizó esta actividad';

-- ========================================
-- VISTAS
-- ========================================

-- Vista: Turnos con asignaciones completas
CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,

    -- Asignación
    a.id AS asignacion_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.combustible_inicial,
    a.combustible_asignado,
    a.hora_salida,
    a.hora_entrada_estimada,

    -- Tripulación (JSON array)
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', usr.id,
                'nombre', usr.nombre_completo,
                'rol', tc.rol_tripulacion,
                'presente', tc.presente
            )
            ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc
        JOIN usuario usr ON tc.usuario_id = usr.id
        WHERE tc.asignacion_id = a.id
    ) AS tripulacion,

    -- Último reporte horario
    (
        SELECT json_build_object(
            'km', rh.km_actual,
            'sentido', rh.sentido_actual,
            'novedad', rh.novedad,
            'hora', rh.created_at
        )
        FROM reporte_horario rh
        WHERE rh.asignacion_id = a.id
        ORDER BY rh.created_at DESC
        LIMIT 1
    ) AS ultimo_reporte,

    t.created_at

FROM turno t
JOIN asignacion_unidad a ON t.id = a.turno_id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
ORDER BY t.fecha DESC, u.codigo;

COMMENT ON VIEW v_turnos_completos IS 'Vista completa de turnos con asignaciones y tripulaciones';

-- Vista: Mi asignación del día (para app móvil)
CREATE OR REPLACE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,

    -- Turno
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,

    -- Asignación
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Mi rol
    tc.rol_tripulacion AS mi_rol,

    -- Zona asignada
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,

    -- Horario
    a.hora_salida,
    a.hora_entrada_estimada,

    -- Compañeros de tripulación
    (
        SELECT json_agg(
            json_build_object(
                'nombre', u2.nombre_completo,
                'rol', tc2.rol_tripulacion
            )
            ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
          AND tc2.usuario_id != usr.id
    ) AS companeros

FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE t.fecha = CURRENT_DATE
  AND t.estado IN ('PLANIFICADO', 'ACTIVO');

COMMENT ON VIEW v_mi_asignacion_hoy IS 'Asignación del día para un usuario (usado en app móvil)';

-- ========================================
-- FUNCIONES
-- ========================================

-- Función: Activar turno automáticamente al inicio del día
CREATE OR REPLACE FUNCTION activar_turno_del_dia()
RETURNS void AS $$
BEGIN
    UPDATE turno
    SET estado = 'ACTIVO'
    WHERE fecha = CURRENT_DATE
      AND estado = 'PLANIFICADO';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION activar_turno_del_dia IS 'Activa el turno del día actual. Ejecutar con cron a las 00:01';

-- Función: Cerrar turno automáticamente
CREATE OR REPLACE FUNCTION cerrar_turno()
RETURNS void AS $$
BEGIN
    UPDATE turno
    SET estado = 'CERRADO'
    WHERE fecha < CURRENT_DATE
      AND estado = 'ACTIVO';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cerrar_turno IS 'Cierra turnos de días anteriores. Ejecutar con cron a las 23:59';

-- Función: Calcular kilometraje recorrido
CREATE OR REPLACE FUNCTION calcular_km_recorridos()
RETURNS TRIGGER AS $$
DECLARE
    km_inicial DECIMAL(6,2);
    km_minimo DECIMAL(6,2);
    km_maximo DECIMAL(6,2);
BEGIN
    -- Obtener km inicial de la asignación
    SELECT a.km_inicio INTO km_inicial
    FROM asignacion_unidad a
    WHERE a.id = NEW.asignacion_id;

    -- Calcular km recorridos basado en reportes horarios
    SELECT
        MIN(rh.km_actual),
        MAX(rh.km_actual)
    INTO km_minimo, km_maximo
    FROM reporte_horario rh
    WHERE rh.asignacion_id = NEW.asignacion_id;

    -- Actualizar km recorridos en la asignación
    UPDATE asignacion_unidad
    SET km_recorridos = COALESCE(ABS(km_maximo - km_minimo), 0)
    WHERE id = NEW.asignacion_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcular_km_recorridos
    AFTER INSERT ON reporte_horario
    FOR EACH ROW
    EXECUTE FUNCTION calcular_km_recorridos();

COMMENT ON FUNCTION calcular_km_recorridos IS 'Calcula automáticamente los km recorridos al agregar reporte horario';
