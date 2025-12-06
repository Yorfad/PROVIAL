-- Script simple para configurar usuario brigada01

-- 1. Configurar usuario brigada01
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- 2. Asegurar que hay un turno para hoy
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
    SELECT id INTO v_unidad_id FROM unidad WHERE activa = TRUE LIMIT 1;

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
            (SELECT id FROM ruta LIMIT 1),
            '06:00:00'::TIME,
            '18:00:00'::TIME,
            'ASIGNADA',
            1
        )
        RETURNING id INTO v_asignacion_id;
    END IF;

    -- Verificar si ya existe tripulación para brigada01 en la asignación
    IF NOT EXISTS (
        SELECT 1 FROM tripulacion_turno
        WHERE asignacion_id = v_asignacion_id
          AND usuario_id = v_usuario_id
    ) THEN
        -- Agregar brigada01 a la tripulación
        INSERT INTO tripulacion_turno (
            asignacion_id,
            usuario_id,
            rol_tripulacion,
            presente
        )
        VALUES (
            v_asignacion_id,
            v_usuario_id,
            'PILOTO',
            TRUE
        );
    END IF;

    RAISE NOTICE 'Usuario brigada01 configurado correctamente';
    RAISE NOTICE 'Turno ID: %', v_turno_id;
    RAISE NOTICE 'Unidad ID: %', v_unidad_id;
    RAISE NOTICE 'Asignación ID: %', v_asignacion_id;
END $$;

-- 3. Verificar configuración
SELECT
    'Usuario' AS tipo,
    id::TEXT,
    username AS detalle,
    grupo::TEXT AS info1,
    acceso_app_activo::TEXT AS info2
FROM usuario
WHERE username = 'brigada01'

UNION ALL

SELECT
    'Turno' AS tipo,
    t.id::TEXT,
    t.fecha::TEXT AS detalle,
    t.estado AS info1,
    '' AS info2
FROM turno t
WHERE t.fecha = CURRENT_DATE

UNION ALL

SELECT
    'Asignación' AS tipo,
    au.id::TEXT,
    u.codigo AS detalle,
    au.estado AS info1,
    r.codigo AS info2
FROM asignacion_unidad au
JOIN turno t ON au.turno_id = t.id
JOIN unidad u ON au.unidad_id = u.id
LEFT JOIN ruta r ON au.ruta_asignada_id = r.id
WHERE t.fecha = CURRENT_DATE

UNION ALL

SELECT
    'Tripulación' AS tipo,
    tt.id::TEXT,
    us.username AS detalle,
    tt.rol_tripulacion AS info1,
    tt.presente::TEXT AS info2
FROM tripulacion_turno tt
JOIN usuario us ON tt.usuario_id = us.id
JOIN asignacion_unidad au ON tt.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
WHERE t.fecha = CURRENT_DATE
  AND us.username = 'brigada01';
