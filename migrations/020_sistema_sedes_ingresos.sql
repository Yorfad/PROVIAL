-- Migración 020: Sistema de Sedes e Ingresos Múltiples
-- Implementa: sedes, jurisdicción, ingresos múltiples durante salida, finalización de día laboral

-- ========================================
-- 1. TABLA: SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS sede (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,

    -- Ubicación
    departamento_id INT REFERENCES departamento(id) ON DELETE RESTRICT,
    municipio_id INT REFERENCES municipio(id) ON DELETE RESTRICT,
    direccion TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),

    -- Contacto
    telefono VARCHAR(50),
    email VARCHAR(100),

    -- Estado
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    es_sede_central BOOLEAN NOT NULL DEFAULT FALSE,

    -- Metadata
    observaciones TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sede IS 'Sedes de PROVIAL distribuidas por el país';
COMMENT ON COLUMN sede.es_sede_central IS 'TRUE si es la sede central (Guatemala)';
COMMENT ON COLUMN sede.activa IS 'FALSE si la sede fue cerrada o está inactiva';

CREATE INDEX idx_sede_codigo ON sede(codigo);
CREATE INDEX idx_sede_activa ON sede(activa) WHERE activa = TRUE;

-- Solo una sede central
CREATE UNIQUE INDEX idx_una_sede_central
    ON sede(es_sede_central)
    WHERE es_sede_central = TRUE;

-- Trigger para updated_at
CREATE TRIGGER update_sede_updated_at
    BEFORE UPDATE ON sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 2. MODIFICAR TABLAS EXISTENTES - Agregar sede_id
-- ========================================

-- Usuario pertenece a una sede
ALTER TABLE usuario
ADD COLUMN IF NOT EXISTS sede_id INT REFERENCES sede(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_usuario_sede ON usuario(sede_id);

COMMENT ON COLUMN usuario.sede_id IS 'Sede a la que pertenece el usuario. NULL = acceso a todas (COP)';

-- Unidad pertenece a una sede
ALTER TABLE unidad
ADD COLUMN IF NOT EXISTS sede_id INT REFERENCES unidad(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_unidad_sede ON unidad(sede_id);

COMMENT ON COLUMN unidad.sede_id IS 'Sede base de la unidad';

-- ========================================
-- 3. TABLA: REASIGNACION_SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS reasignacion_sede (
    id SERIAL PRIMARY KEY,

    -- Puede ser usuario o unidad
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('USUARIO', 'UNIDAD')),
    recurso_id INT NOT NULL, -- ID del usuario o unidad

    -- Reasignación
    sede_origen_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,
    sede_destino_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,

    -- Temporalidad
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE, -- NULL = permanente
    es_permanente BOOLEAN NOT NULL DEFAULT FALSE,

    -- Motivo
    motivo TEXT,
    -- Ejemplo: "Apoyo en reparación de puente", "Cobertura de carrera de ciclismo"

    -- Estado
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA'
        CHECK (estado IN ('ACTIVA', 'FINALIZADA', 'CANCELADA')),

    -- Auditoría
    autorizado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reasignacion_sede IS 'Reasignaciones temporales o permanentes de personal/unidades entre sedes';
COMMENT ON COLUMN reasignacion_sede.tipo IS 'USUARIO: brigadista | UNIDAD: vehículo';
COMMENT ON COLUMN reasignacion_sede.recurso_id IS 'ID del usuario o unidad reasignado';

CREATE INDEX idx_reasignacion_tipo_recurso ON reasignacion_sede(tipo, recurso_id);
CREATE INDEX idx_reasignacion_estado ON reasignacion_sede(estado);
CREATE INDEX idx_reasignacion_fechas ON reasignacion_sede(fecha_inicio, fecha_fin);

-- Trigger para updated_at
CREATE TRIGGER update_reasignacion_sede_updated_at
    BEFORE UPDATE ON reasignacion_sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 4. TABLA: INGRESO_SEDE
-- ========================================

CREATE TABLE IF NOT EXISTS ingreso_sede (
    id SERIAL PRIMARY KEY,

    -- Salida a la que pertenece este ingreso
    salida_unidad_id INT NOT NULL REFERENCES salida_unidad(id) ON DELETE CASCADE,

    -- Sede a la que ingresa
    sede_id INT NOT NULL REFERENCES sede(id) ON DELETE RESTRICT,

    -- Timing
    fecha_hora_ingreso TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_hora_salida TIMESTAMPTZ, -- NULL mientras esté ingresado

    -- Tipo de ingreso
    tipo_ingreso VARCHAR(30) NOT NULL
        CHECK (tipo_ingreso IN ('COMBUSTIBLE', 'COMISION', 'APOYO', 'ALMUERZO', 'MANTENIMIENTO', 'FINALIZACION')),

    -- Datos del ingreso
    km_ingreso DECIMAL(8,2),
    combustible_ingreso DECIMAL(5,2),

    -- Datos de salida (si vuelve a salir)
    km_salida_nueva DECIMAL(8,2),
    combustible_salida_nueva DECIMAL(5,2),

    -- Observaciones
    observaciones_ingreso TEXT,
    observaciones_salida TEXT,

    -- Es el ingreso final? (finalización del día laboral)
    es_ingreso_final BOOLEAN NOT NULL DEFAULT FALSE,

    -- Auditoría
    registrado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ingreso_sede IS 'Ingresos de unidades a sedes durante una salida. Puede haber múltiples ingresos por salida.';
COMMENT ON COLUMN ingreso_sede.tipo_ingreso IS 'Motivo del ingreso a sede';
COMMENT ON COLUMN ingreso_sede.es_ingreso_final IS 'TRUE si es el ingreso que finaliza la jornada laboral';
COMMENT ON COLUMN ingreso_sede.fecha_hora_salida IS 'NULL si todavía está ingresado, timestamp si volvió a salir';

CREATE INDEX idx_ingreso_salida ON ingreso_sede(salida_unidad_id);
CREATE INDEX idx_ingreso_sede_sede ON ingreso_sede(sede_id);
CREATE INDEX idx_ingreso_fecha ON ingreso_sede(fecha_hora_ingreso DESC);

-- Solo un ingreso activo (sin fecha_hora_salida) por salida
CREATE UNIQUE INDEX idx_ingreso_activo_por_salida
    ON ingreso_sede(salida_unidad_id)
    WHERE fecha_hora_salida IS NULL;

COMMENT ON INDEX idx_ingreso_activo_por_salida IS 'Garantiza que una salida solo tenga un ingreso activo a la vez';

-- Trigger para updated_at
CREATE TRIGGER update_ingreso_sede_updated_at
    BEFORE UPDATE ON ingreso_sede
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 5. MODIFICAR TABLA SALIDA_UNIDAD
-- ========================================

-- Agregar sede de origen (de donde salió)
ALTER TABLE salida_unidad
ADD COLUMN IF NOT EXISTS sede_origen_id INT REFERENCES sede(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_salida_sede_origen ON salida_unidad(sede_origen_id);

COMMENT ON COLUMN salida_unidad.sede_origen_id IS 'Sede desde donde salió la unidad';

-- ========================================
-- 6. VISTAS ACTUALIZADAS
-- ========================================

-- Vista: Mi unidad asignada (CON SEDE)
DROP VIEW IF EXISTS v_mi_unidad_asignada;
CREATE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,

    -- Sede del brigadista
    u.sede_id AS mi_sede_id,
    s.codigo AS mi_sede_codigo,
    s.nombre AS mi_sede_nombre,

    -- Unidad asignada
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,

    -- Sede de la unidad
    un.sede_id AS unidad_sede_id,
    su.codigo AS unidad_sede_codigo,
    su.nombre AS unidad_sede_nombre,

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
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN sede su ON un.sede_id = su.id
WHERE bu.activo = TRUE;

-- Vista: Salida activa CON ingresos
DROP VIEW IF EXISTS v_mi_salida_activa;
CREATE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,

    -- Salida
    sal.id AS salida_id,
    sal.unidad_id,
    un.codigo AS unidad_codigo,
    sal.estado,
    sal.fecha_hora_salida,
    sal.fecha_hora_regreso,

    -- Sede origen
    sal.sede_origen_id,
    so.codigo AS sede_origen_codigo,
    so.nombre AS sede_origen_nombre,

    -- Duración
    EXTRACT(EPOCH FROM (COALESCE(sal.fecha_hora_regreso, NOW()) - sal.fecha_hora_salida)) / 3600 AS horas_salida,

    -- Ruta inicial
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    sal.km_inicial,
    sal.combustible_inicial,

    -- Tripulación
    sal.tripulacion,

    -- Ingreso activo (si está ingresado en alguna sede)
    (
        SELECT json_build_object(
            'id', i.id,
            'sede_id', i.sede_id,
            'sede_codigo', se.codigo,
            'sede_nombre', se.nombre,
            'tipo', i.tipo_ingreso,
            'fecha_hora_ingreso', i.fecha_hora_ingreso,
            'km_ingreso', i.km_ingreso,
            'es_ingreso_final', i.es_ingreso_final
        )
        FROM ingreso_sede i
        JOIN sede se ON i.sede_id = se.id
        WHERE i.salida_unidad_id = sal.id
          AND i.fecha_hora_salida IS NULL
        LIMIT 1
    ) AS ingreso_activo,

    -- Cantidad de ingresos realizados
    (
        SELECT COUNT(*)
        FROM ingreso_sede i
        WHERE i.salida_unidad_id = sal.id
    ) AS total_ingresos,

    -- Primera situación
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = sal.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion

FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad sal ON un.id = sal.unidad_id AND sal.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON sal.ruta_inicial_id = r.id
LEFT JOIN sede so ON sal.sede_origen_id = so.id;

-- Vista: Unidades en salida CON sedes
DROP VIEW IF EXISTS v_unidades_en_salida;
CREATE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,

    -- Sede de la unidad
    u.sede_id,
    s.codigo AS sede_codigo,
    s.nombre AS sede_nombre,

    -- Salida activa
    sal.id AS salida_id,
    sal.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - sal.fecha_hora_salida)) / 3600 AS horas_en_salida,

    -- Sede origen de la salida
    sal.sede_origen_id,
    so.codigo AS sede_origen_codigo,

    -- Ruta
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    sal.km_inicial,

    -- Tripulación
    sal.tripulacion,

    -- ¿Está ingresada en alguna sede?
    EXISTS (
        SELECT 1 FROM ingreso_sede i
        WHERE i.salida_unidad_id = sal.id
          AND i.fecha_hora_salida IS NULL
    ) AS esta_ingresada,

    -- Cantidad de situaciones
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = sal.id
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
        WHERE sit.salida_unidad_id = sal.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion

FROM unidad u
JOIN salida_unidad sal ON u.id = sal.unidad_id AND sal.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON sal.ruta_inicial_id = r.id
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN sede so ON sal.sede_origen_id = so.id
ORDER BY sal.fecha_hora_salida DESC;

-- ========================================
-- 7. FUNCIONES
-- ========================================

-- Función: Obtener sede efectiva de usuario (considerando reasignaciones)
CREATE OR REPLACE FUNCTION obtener_sede_efectiva_usuario(p_usuario_id INT)
RETURNS INT AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignación activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'USUARIO'
      AND recurso_id = p_usuario_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignación, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM usuario
        WHERE id = p_usuario_id;
    END IF;

    RETURN v_sede_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_sede_efectiva_usuario IS 'Retorna la sede efectiva del usuario considerando reasignaciones temporales';

-- Función: Obtener sede efectiva de unidad
CREATE OR REPLACE FUNCTION obtener_sede_efectiva_unidad(p_unidad_id INT)
RETURNS INT AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignación activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'UNIDAD'
      AND recurso_id = p_unidad_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignación, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM unidad
        WHERE id = p_unidad_id;
    END IF;

    RETURN v_sede_id;
END;
$$ LANGUAGE plpgsql;

-- Función: Verificar si usuario tiene permiso sobre sede
CREATE OR REPLACE FUNCTION tiene_permiso_sede(
    p_usuario_id INT,
    p_sede_id INT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_rol VARCHAR(50);
    v_sede_usuario INT;
BEGIN
    -- Obtener rol del usuario
    SELECT r.nombre INTO v_rol
    FROM usuario u
    JOIN rol r ON u.rol_id = r.id
    WHERE u.id = p_usuario_id;

    -- COP tiene acceso a TODAS las sedes
    IF v_rol = 'COP' THEN
        RETURN TRUE;
    END IF;

    -- Otros roles solo tienen acceso a su sede
    v_sede_usuario := obtener_sede_efectiva_usuario(p_usuario_id);

    RETURN v_sede_usuario = p_sede_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION tiene_permiso_sede IS 'Verifica si un usuario tiene permiso para operar en una sede. COP tiene acceso universal.';

-- Función: Registrar ingreso a sede
CREATE OR REPLACE FUNCTION registrar_ingreso_sede(
    p_salida_id INT,
    p_sede_id INT,
    p_tipo_ingreso VARCHAR,
    p_km_ingreso DECIMAL DEFAULT NULL,
    p_combustible_ingreso DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_es_ingreso_final BOOLEAN DEFAULT FALSE,
    p_registrado_por INT DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_ingreso_id INT;
    v_ingreso_existente INT;
BEGIN
    -- Verificar que no haya ingreso activo
    SELECT id INTO v_ingreso_existente
    FROM ingreso_sede
    WHERE salida_unidad_id = p_salida_id
      AND fecha_hora_salida IS NULL;

    IF v_ingreso_existente IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un ingreso activo para esta salida (ID: %)', v_ingreso_existente;
    END IF;

    -- Crear ingreso
    INSERT INTO ingreso_sede (
        salida_unidad_id,
        sede_id,
        tipo_ingreso,
        km_ingreso,
        combustible_ingreso,
        observaciones_ingreso,
        es_ingreso_final,
        registrado_por
    )
    VALUES (
        p_salida_id,
        p_sede_id,
        p_tipo_ingreso,
        p_km_ingreso,
        p_combustible_ingreso,
        p_observaciones,
        p_es_ingreso_final,
        p_registrado_por
    )
    RETURNING id INTO v_ingreso_id;

    -- Si es ingreso final, marcar salida como FINALIZADA
    IF p_es_ingreso_final THEN
        UPDATE salida_unidad
        SET estado = 'FINALIZADA',
            fecha_hora_regreso = NOW(),
            km_final = p_km_ingreso,
            combustible_final = p_combustible_ingreso
        WHERE id = p_salida_id;
    END IF;

    RETURN v_ingreso_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_ingreso_sede IS 'Registra ingreso de unidad a sede. Si es_ingreso_final=TRUE, finaliza la salida.';

-- Función: Registrar salida de sede (volver a la calle)
CREATE OR REPLACE FUNCTION registrar_salida_de_sede(
    p_ingreso_id INT,
    p_km_salida DECIMAL DEFAULT NULL,
    p_combustible_salida DECIMAL DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE ingreso_sede
    SET fecha_hora_salida = NOW(),
        km_salida_nueva = p_km_salida,
        combustible_salida_nueva = p_combustible_salida,
        observaciones_salida = p_observaciones
    WHERE id = p_ingreso_id
      AND fecha_hora_salida IS NULL
      AND es_ingreso_final = FALSE; -- No se puede salir de un ingreso final

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_salida_de_sede IS 'Marca que la unidad volvió a salir después de un ingreso temporal';

-- ========================================
-- 8. DATOS INICIALES - SEDES
-- ========================================

-- Insertar sedes principales de Guatemala
INSERT INTO sede (codigo, nombre, es_sede_central, activa, observaciones)
VALUES
    ('CENTRAL', 'Sede Central Guatemala', TRUE, TRUE, 'Oficinas centrales de PROVIAL'),
    ('SANCRISTO', 'Sede San Cristóbal', FALSE, TRUE, 'Sede regional San Cristóbal')
ON CONFLICT (codigo) DO NOTHING;

-- Actualizar unidades existentes con sede central por defecto
UPDATE unidad
SET sede_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_id IS NULL;

-- Actualizar usuarios existentes con sede central por defecto
UPDATE usuario
SET sede_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_id IS NULL
  AND rol_id != (SELECT id FROM rol WHERE nombre = 'COP'); -- COP no tiene sede específica

-- Actualizar salidas existentes con sede origen
UPDATE salida_unidad
SET sede_origen_id = (SELECT id FROM sede WHERE codigo = 'CENTRAL')
WHERE sede_origen_id IS NULL;
