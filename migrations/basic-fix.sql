-- Script básico para configurar brigada01

-- 1. Configurar usuario brigada01 con grupo y acceso
UPDATE usuario
SET
    grupo = 1,
    fecha_inicio_ciclo = CURRENT_DATE,
    acceso_app_activo = TRUE,
    exento_grupos = FALSE
WHERE username = 'brigada01';

-- 2. Asegurar que hay un turno para hoy y asignar brigada01
DO $$
DECLARE
    v_turno_id INT;
    v_unidad_id INT;
    v_usuario_id INT;
    v_asignacion_id INT;
    v_ruta_id INT;
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

    -- Obtener una unidad y ruta
    SELECT id INTO v_unidad_id FROM unidad WHERE activa = TRUE LIMIT 1;
    SELECT id INTO v_ruta_id FROM ruta LIMIT 1;

    -- Obtener el ID del usuario brigada01
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';

    -- Crear o actualizar asignación
    INSERT INTO asignacion_unidad (
        turno_id,
        unidad_id,
        ruta_id,
        km_inicio,
        km_final,
        sentido,
        combustible_inicial,
        hora_salida
    )
    VALUES (
        v_turno_id,
        v_unidad_id,
        v_ruta_id,
        0,
        999,
        'AMBOS',
        80,
        '06:00:00'::TIME
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_asignacion_id;

    -- Si no se insertó (porque ya existía), obtener el ID
    IF v_asignacion_id IS NULL THEN
        SELECT id INTO v_asignacion_id
        FROM asignacion_unidad
        WHERE turno_id = v_turno_id
          AND unidad_id = v_unidad_id
        LIMIT 1;
    END IF;

    -- Agregar brigada01 a la tripulación si no existe
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
    )
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Usuario brigada01 configurado';
    RAISE NOTICE 'Turno ID: %, Unidad ID: %, Asignación ID: %', v_turno_id, v_unidad_id, v_asignacion_id;
END $$;

-- 3. Verificar configuración final
SELECT
    u.username,
    u.grupo,
    u.acceso_app_activo,
    t.fecha AS turno_fecha,
    un.codigo AS unidad,
    r.codigo AS ruta,
    tt.rol_tripulacion
FROM usuario u
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN unidad un ON au.unidad_id = un.id
LEFT JOIN ruta r ON au.ruta_id = r.id
WHERE u.username = 'brigada01'
  AND (t.fecha = CURRENT_DATE OR t.fecha IS NULL)
LIMIT 1;
