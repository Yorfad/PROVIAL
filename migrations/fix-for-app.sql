-- Script para arreglar problemas de la app móvil

-- ========================================
-- 1. ELIMINAR ÍNDICES QUE DEPENDEN DE POSTGIS
-- ========================================

DROP INDEX IF EXISTS idx_situacion_ubicacion;

-- ========================================
-- 2. CREAR VISTA V_SITUACIONES_COMPLETAS (si no existe)
-- ========================================

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

COMMENT ON VIEW v_situaciones_completas IS 'Vista completa de situaciones con datos relacionados';

-- ========================================
-- 3. ASEGURAR QUE LA TABLA USUARIO TENGA LAS COLUMNAS NECESARIAS
-- ========================================

DO $$
BEGIN
    -- Agregar columna grupo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'grupo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN grupo SMALLINT CHECK (grupo IN (1, 2));
    END IF;

    -- Agregar columna fecha_inicio_ciclo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'fecha_inicio_ciclo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN fecha_inicio_ciclo DATE;
    END IF;

    -- Agregar columna acceso_app_activo si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'acceso_app_activo'
    ) THEN
        ALTER TABLE usuario ADD COLUMN acceso_app_activo BOOLEAN DEFAULT TRUE;
    END IF;

    -- Agregar columna exento_grupos si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'exento_grupos'
    ) THEN
        ALTER TABLE usuario ADD COLUMN exento_grupos BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- ========================================
-- 4. CONFIGURAR USUARIO BRIGADA01
-- ========================================

-- Actualizar usuario brigada01 para que tenga grupo y acceso
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- ========================================
-- 5. ASIGNAR UNIDAD Y TRIPULACIÓN A BRIGADA01
-- ========================================

-- Primero, verificar que existe un turno para hoy
DO $$
DECLARE
    v_turno_id INT;
    v_unidad_id INT;
    v_usuario_id INT;
    v_asignacion_id INT;
BEGIN
    -- Obtener turno de hoy o crear uno
    SELECT id INTO v_turno_id
    FROM turno
    WHERE fecha = CURRENT_DATE;

    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (CURRENT_DATE, 'ACTIVO', 'Turno para pruebas', 1)
        RETURNING id INTO v_turno_id;
    END IF;

    -- Obtener una unidad (la primera disponible)
    SELECT id INTO v_unidad_id FROM unidad LIMIT 1;

    -- Obtener el ID del usuario brigada01
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';

    -- Verificar si ya tiene asignación hoy
    SELECT id INTO v_asignacion_id
    FROM asignacion_unidad
    WHERE turno_id = v_turno_id
      AND unidad_id = v_unidad_id;

    -- Si no existe asignación, crear una
    IF v_asignacion_id IS NULL THEN
        -- Crear asignación de unidad
        INSERT INTO asignacion_unidad (
            turno_id,
            unidad_id,
            ruta_asignada_id,
            hora_inicio_asignada,
            hora_fin_asignada,
            estado,
            creado_por
        )
        VALUES (
            v_turno_id,
            v_unidad_id,
            (SELECT id FROM ruta LIMIT 1),  -- Primera ruta disponible
            '06:00:00'::TIME,
            '18:00:00'::TIME,
            'ASIGNADA',
            1
        )
        RETURNING id INTO v_asignacion_id;
    END IF;

    -- Verificar si ya existe tripulación para brigada01
    IF NOT EXISTS (
        SELECT 1 FROM tripulacion_unidad
        WHERE asignacion_id = v_asignacion_id
          AND usuario_id = v_usuario_id
    ) THEN
        -- Agregar brigada01 a la tripulación como piloto
        INSERT INTO tripulacion_unidad (
            asignacion_id,
            usuario_id,
            es_piloto,
            hora_entrada,
            estado,
            creado_por
        )
        VALUES (
            v_asignacion_id,
            v_usuario_id,
            TRUE,  -- Es piloto
            NOW(),
            'PRESENTE',
            1
        );
    END IF;
END $$;

-- ========================================
-- 6. CREAR CALENDARIO DE GRUPOS SI NO EXISTE
-- ========================================

DO $$
BEGIN
    -- Solo si existe la función generar_calendario_grupos
    IF EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'generar_calendario_grupos'
    ) THEN
        -- Generar calendario para los próximos 90 días si no existe
        IF NOT EXISTS (SELECT 1 FROM calendario_grupo WHERE fecha = CURRENT_DATE) THEN
            PERFORM generar_calendario_grupos(CURRENT_DATE, CURRENT_DATE + INTERVAL '90 days');
        END IF;
    END IF;
END $$;

-- ========================================
-- 7. VERIFICAR CONFIGURACIÓN
-- ========================================

-- Mostrar configuración del usuario brigada01
SELECT
    id,
    username,
    nombre_completo,
    rol,
    grupo,
    fecha_inicio_ciclo,
    acceso_app_activo,
    exento_grupos,
    activo
FROM usuario
WHERE username = 'brigada01';

-- Mostrar asignación de hoy
SELECT
    au.id AS asignacion_id,
    u.codigo AS unidad_codigo,
    r.codigo AS ruta_codigo,
    t.fecha AS turno_fecha,
    au.estado AS asignacion_estado
FROM asignacion_unidad au
JOIN unidad u ON au.unidad_id = u.id
JOIN turno t ON au.turno_id = t.id
LEFT JOIN ruta r ON au.ruta_asignada_id = r.id
WHERE t.fecha = CURRENT_DATE
  AND EXISTS (
      SELECT 1 FROM tripulacion_unidad tu
      WHERE tu.asignacion_id = au.id
        AND tu.usuario_id = (SELECT id FROM usuario WHERE username = 'brigada01')
  );

-- Mostrar tripulación
SELECT
    tu.id,
    u.nombre_completo,
    tu.es_piloto,
    tu.estado,
    tu.hora_entrada
FROM tripulacion_unidad tu
JOIN usuario u ON tu.usuario_id = u.id
JOIN asignacion_unidad au ON tu.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
WHERE t.fecha = CURRENT_DATE
  AND u.username = 'brigada01';
