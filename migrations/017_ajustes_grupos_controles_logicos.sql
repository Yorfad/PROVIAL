-- Migración 017: Ajustes al sistema de grupos y controles lógicos

-- ========================================
-- MODIFICAR TABLA USUARIO: Exentos de grupos
-- ========================================

ALTER TABLE usuario
ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN usuario.exento_grupos IS 'True si el usuario está exento del sistema de grupos (admins, jefes)';

-- Actualizar usuarios exentos automáticamente (ADMIN, OPERACIONES, MANDOS)
UPDATE usuario
SET exento_grupos = TRUE
WHERE rol_nombre IN ('ADMIN', 'OPERACIONES', 'MANDOS', 'ACCIDENTOLOGIA');

CREATE INDEX idx_usuario_exento ON usuario(exento_grupos) WHERE exento_grupos = TRUE;

-- ========================================
-- TABLA: REGISTRO_CAMBIOS (Auditoría detallada)
-- ========================================

CREATE TABLE registro_cambio (
    id BIGSERIAL PRIMARY KEY,

    -- Tipo de cambio
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN (
        'CAMBIO_BRIGADA',           -- Cambio de brigada en asignación
        'CAMBIO_UNIDAD',            -- Cambio de unidad
        'REMOCION_ASIGNACION',      -- Remover brigada de asignación
        'SUSPENSION_ACCESO',        -- Suspender acceso a app
        'REACTIVACION_ACCESO',      -- Reactivar acceso
        'CAMBIO_GRUPO',             -- Cambiar de grupo 1 a 2 o viceversa
        'EDICION_SITUACION',        -- Editar situación de día cerrado
        'EDICION_ASIGNACION',       -- Editar asignación de día cerrado
        'OTRO'
    )),

    -- Entidades afectadas
    usuario_afectado_id INT REFERENCES usuario(id) ON DELETE SET NULL,
    asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL,
    situacion_id BIGINT REFERENCES situacion(id) ON DELETE SET NULL,
    unidad_id INT REFERENCES unidad(id) ON DELETE SET NULL,

    -- Valores anteriores y nuevos (JSON para flexibilidad)
    valores_anteriores JSONB,
    valores_nuevos JSONB,

    -- Motivo del cambio (OBLIGATORIO)
    motivo TEXT NOT NULL,

    -- Quien autorizó/realizó el cambio
    realizado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
    autorizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Auditoría
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE registro_cambio IS 'Registro de auditoría de todos los cambios realizados en el sistema';
COMMENT ON COLUMN registro_cambio.motivo IS 'Motivo obligatorio para el cambio (ej: "Brigada enfermo", "Unidad con falla mecánica")';
COMMENT ON COLUMN registro_cambio.valores_anteriores IS 'Estado anterior en JSON';
COMMENT ON COLUMN registro_cambio.valores_nuevos IS 'Estado nuevo en JSON';

-- Índices
CREATE INDEX idx_registro_tipo ON registro_cambio(tipo_cambio);
CREATE INDEX idx_registro_usuario ON registro_cambio(usuario_afectado_id);
CREATE INDEX idx_registro_asignacion ON registro_cambio(asignacion_id);
CREATE INDEX idx_registro_fecha ON registro_cambio(created_at DESC);
CREATE INDEX idx_registro_realizado_por ON registro_cambio(realizado_por);

-- ========================================
-- MODIFICAR TABLA ASIGNACION_UNIDAD: Campos de auditoría
-- ========================================

ALTER TABLE asignacion_unidad
ADD COLUMN modificado_despues_cierre BOOLEAN DEFAULT FALSE,
ADD COLUMN motivo_modificacion_cierre TEXT;

COMMENT ON COLUMN asignacion_unidad.modificado_despues_cierre IS 'True si fue modificado después de que el día fue cerrado';
COMMENT ON COLUMN asignacion_unidad.motivo_modificacion_cierre IS 'Motivo de la modificación post-cierre';

-- ========================================
-- MODIFICAR TABLA SITUACION: Campos de auditoría
-- ========================================

ALTER TABLE situacion
ADD COLUMN modificado_despues_cierre BOOLEAN DEFAULT FALSE,
ADD COLUMN motivo_modificacion_cierre TEXT;

COMMENT ON COLUMN situacion.modificado_despues_cierre IS 'True si fue modificado después de cerrar el día';
COMMENT ON COLUMN situacion.motivo_modificacion_cierre IS 'Motivo de la modificación post-cierre';

-- ========================================
-- REMOVER TABLA CONTROL_ACCESO_APP: Simplificar
-- ========================================
-- La lógica se manejará directamente con campos en usuario + verificación de grupos

DROP TABLE IF EXISTS control_acceso_app;

-- ========================================
-- FUNCIONES ACTUALIZADAS
-- ========================================

-- Función: Verificar acceso app (versión mejorada)
DROP FUNCTION IF EXISTS verificar_acceso_app(INT);

CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
    tiene_acceso BOOLEAN,
    motivo_bloqueo TEXT
) AS $$
DECLARE
    v_usuario RECORD;
    v_grupo_en_descanso BOOLEAN;
    v_tiene_asignacion_activa BOOLEAN;
BEGIN
    -- Obtener datos del usuario
    SELECT
        u.id,
        u.rol_nombre,
        u.grupo,
        u.acceso_app_activo,
        u.exento_grupos,
        u.activo
    INTO v_usuario
    FROM usuario u
    WHERE u.id = p_usuario_id;

    -- Validación: Usuario existe y está activo
    IF v_usuario.id IS NULL OR v_usuario.activo = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Usuario inactivo o no existe';
        RETURN;
    END IF;

    -- 1. Usuarios exentos (ADMIN, OPERACIONES, MANDOS) siempre tienen acceso
    IF v_usuario.exento_grupos = TRUE THEN
        -- Solo verificar acceso individual
        IF v_usuario.acceso_app_activo = FALSE THEN
            RETURN QUERY SELECT FALSE, 'Acceso suspendido administrativamente';
            RETURN;
        END IF;
        RETURN QUERY SELECT TRUE, NULL::TEXT;
        RETURN;
    END IF;

    -- 2. Verificar acceso individual
    IF v_usuario.acceso_app_activo = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso suspendido';
        RETURN;
    END IF;

    -- 3. Verificar si el grupo está en descanso (solo para BRIGADA)
    IF v_usuario.rol_nombre = 'BRIGADA' AND v_usuario.grupo IS NOT NULL THEN
        SELECT NOT esta_de_turno
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_usuario.grupo;

        IF v_grupo_en_descanso THEN
            -- Verificar si tiene asignación activa excepcional
            SELECT EXISTS (
                SELECT 1
                FROM tripulacion_turno tt
                JOIN asignacion_unidad au ON tt.asignacion_id = au.id
                JOIN turno t ON au.turno_id = t.id
                WHERE tt.usuario_id = p_usuario_id
                  AND t.fecha = CURRENT_DATE
                  AND au.dia_cerrado = FALSE
            ) INTO v_tiene_asignacion_activa;

            IF NOT v_tiene_asignacion_activa THEN
                RETURN QUERY SELECT FALSE, 'Grupo en período de descanso';
                RETURN;
            END IF;
        END IF;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION verificar_acceso_app IS 'Verifica acceso a la app: exentos siempre pueden, brigadas dependen de grupo y asignación';

-- Función: Validar antes de suspender acceso
CREATE OR REPLACE FUNCTION validar_suspension_acceso(p_usuario_id INT)
RETURNS TABLE (
    puede_suspender BOOLEAN,
    motivo_rechazo TEXT
) AS $$
DECLARE
    v_tiene_asignacion_activa BOOLEAN;
    v_tiene_movimiento_activo BOOLEAN;
    v_tiene_situacion_activa BOOLEAN;
BEGIN
    -- Verificar asignación activa
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        JOIN turno t ON au.turno_id = t.id
        WHERE tt.usuario_id = p_usuario_id
          AND t.fecha = CURRENT_DATE
          AND au.dia_cerrado = FALSE
    ) INTO v_tiene_asignacion_activa;

    IF v_tiene_asignacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene una asignación activa. Debe ser removido primero.';
        RETURN;
    END IF;

    -- Verificar movimientos activos
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar situaciones activas creadas por él
    SELECT EXISTS (
        SELECT 1
        FROM situacion
        WHERE creado_por = p_usuario_id
          AND estado = 'ACTIVA'
    ) INTO v_tiene_situacion_activa;

    IF v_tiene_situacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene situaciones activas. Deben cerrarse primero.';
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_suspension_acceso IS 'Valida que un usuario pueda tener su acceso suspendido';

-- Función: Validar antes de remover de asignación
CREATE OR REPLACE FUNCTION validar_remocion_asignacion(
    p_usuario_id INT,
    p_asignacion_id INT
)
RETURNS TABLE (
    puede_remover BOOLEAN,
    motivo_rechazo TEXT
) AS $$
DECLARE
    v_tiene_movimiento_activo BOOLEAN;
    v_es_unico_piloto BOOLEAN;
BEGIN
    -- Verificar movimientos activos en esta asignación
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND (origen_asignacion_id = p_asignacion_id OR destino_asignacion_id = p_asignacion_id)
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El brigada tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar si es el único piloto (no se puede remover)
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        WHERE tt.asignacion_id = p_asignacion_id
          AND tt.usuario_id = p_usuario_id
          AND tt.rol_tripulacion = 'PILOTO'
          AND (
            SELECT COUNT(*)
            FROM tripulacion_turno
            WHERE asignacion_id = p_asignacion_id
              AND rol_tripulacion = 'PILOTO'
              AND presente = TRUE
          ) = 1
    ) INTO v_es_unico_piloto;

    IF v_es_unico_piloto THEN
        RETURN QUERY SELECT FALSE, 'No se puede remover al único piloto de la unidad. Asignar otro piloto primero.';
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validar_remocion_asignacion IS 'Valida que un brigada pueda ser removido de una asignación';

-- Función: Registrar cambio con auditoría
CREATE OR REPLACE FUNCTION registrar_cambio(
    p_tipo_cambio VARCHAR(50),
    p_usuario_afectado_id INT,
    p_motivo TEXT,
    p_realizado_por INT,
    p_valores_anteriores JSONB DEFAULT NULL,
    p_valores_nuevos JSONB DEFAULT NULL,
    p_asignacion_id INT DEFAULT NULL,
    p_situacion_id BIGINT DEFAULT NULL,
    p_unidad_id INT DEFAULT NULL,
    p_autorizado_por INT DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_cambio_id BIGINT;
BEGIN
    INSERT INTO registro_cambio (
        tipo_cambio,
        usuario_afectado_id,
        motivo,
        realizado_por,
        valores_anteriores,
        valores_nuevos,
        asignacion_id,
        situacion_id,
        unidad_id,
        autorizado_por
    ) VALUES (
        p_tipo_cambio,
        p_usuario_afectado_id,
        p_motivo,
        p_realizado_por,
        p_valores_anteriores,
        p_valores_nuevos,
        p_asignacion_id,
        p_situacion_id,
        p_unidad_id,
        p_autorizado_por
    )
    RETURNING id INTO v_cambio_id;

    RETURN v_cambio_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_cambio IS 'Registra un cambio en el sistema con auditoría completa';

-- ========================================
-- TRIGGERS: Validaciones automáticas
-- ========================================

-- Trigger: Validar antes de suspender acceso
CREATE OR REPLACE FUNCTION trigger_validar_suspension_acceso()
RETURNS TRIGGER AS $$
DECLARE
    v_validacion RECORD;
BEGIN
    -- Solo validar si se está desactivando el acceso
    IF OLD.acceso_app_activo = TRUE AND NEW.acceso_app_activo = FALSE THEN
        SELECT *
        INTO v_validacion
        FROM validar_suspension_acceso(NEW.id);

        IF v_validacion.puede_suspender = FALSE THEN
            RAISE EXCEPTION 'No se puede suspender acceso: %', v_validacion.motivo_rechazo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_usuario_validar_suspension
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    WHEN (OLD.acceso_app_activo IS DISTINCT FROM NEW.acceso_app_activo)
    EXECUTE FUNCTION trigger_validar_suspension_acceso();

COMMENT ON TRIGGER trigger_usuario_validar_suspension ON usuario IS 'Valida que un usuario pueda tener su acceso suspendido';

-- Trigger: Auditar cambios en asignaciones cerradas
CREATE OR REPLACE FUNCTION trigger_auditar_cambio_asignacion_cerrada()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el día está cerrado y se está modificando
    IF OLD.dia_cerrado = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar asignación de día cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_asignacion_auditar_cierre
    BEFORE UPDATE ON asignacion_unidad
    FOR EACH ROW
    WHEN (OLD.dia_cerrado = TRUE)
    EXECUTE FUNCTION trigger_auditar_cambio_asignacion_cerrada();

-- Trigger: Auditar cambios en situaciones de día cerrado
CREATE OR REPLACE FUNCTION trigger_auditar_cambio_situacion_cerrada()
RETURNS TRIGGER AS $$
DECLARE
    v_asignacion_cerrada BOOLEAN;
BEGIN
    -- Verificar si la asignación está cerrada
    SELECT dia_cerrado
    INTO v_asignacion_cerrada
    FROM asignacion_unidad
    WHERE id = OLD.asignacion_id;

    IF v_asignacion_cerrada = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar situación de día cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_situacion_auditar_cierre
    BEFORE UPDATE ON situacion
    FOR EACH ROW
    EXECUTE FUNCTION trigger_auditar_cambio_situacion_cerrada();

-- ========================================
-- VISTAS ADICIONALES
-- ========================================

-- Vista: Brigadas con asignaciones activas
CREATE OR REPLACE VIEW v_brigadas_con_asignaciones_activas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    t.id AS turno_id,
    t.fecha AS turno_fecha,
    au.id AS asignacion_id,
    un.codigo AS unidad_codigo,
    tt.rol_tripulacion,
    tt.presente,
    au.dia_cerrado
FROM usuario u
JOIN tripulacion_turno tt ON u.id = tt.usuario_id
JOIN asignacion_unidad au ON tt.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
JOIN unidad un ON au.unidad_id = un.id
WHERE t.fecha = CURRENT_DATE
  AND au.dia_cerrado = FALSE
ORDER BY un.codigo, tt.rol_tripulacion;

COMMENT ON VIEW v_brigadas_con_asignaciones_activas IS 'Brigadas que tienen asignaciones activas hoy';

-- Vista: Historial de cambios por usuario
CREATE OR REPLACE VIEW v_historial_cambios_usuario AS
SELECT
    rc.id,
    rc.tipo_cambio,
    rc.usuario_afectado_id,
    u_afectado.nombre_completo AS usuario_afectado,
    rc.motivo,
    rc.valores_anteriores,
    rc.valores_nuevos,
    rc.realizado_por,
    u_realizado.nombre_completo AS realizado_por_nombre,
    rc.autorizado_por,
    u_autorizado.nombre_completo AS autorizado_por_nombre,
    rc.created_at
FROM registro_cambio rc
LEFT JOIN usuario u_afectado ON rc.usuario_afectado_id = u_afectado.id
LEFT JOIN usuario u_realizado ON rc.realizado_por = u_realizado.id
LEFT JOIN usuario u_autorizado ON rc.autorizado_por = u_autorizado.id
ORDER BY rc.created_at DESC;

COMMENT ON VIEW v_historial_cambios_usuario IS 'Historial completo de cambios con información de usuarios';
