
DO $$
DECLARE
    v_usuario_id INTEGER;
    v_unidad_id INTEGER;
    v_ruta_id INTEGER;
    v_turno_id INTEGER;
    v_asignacion_id INTEGER;
BEGIN
    -- 1. Obtener IDs
    SELECT id INTO v_usuario_id FROM usuario WHERE username = 'brigada01';
    IF v_usuario_id IS NULL THEN
        RAISE EXCEPTION 'Usuario brigada01 no encontrado';
    END IF;

    SELECT id INTO v_unidad_id FROM unidad WHERE codigo = '1104';
    IF v_unidad_id IS NULL THEN
        RAISE EXCEPTION 'Unidad 1104 no encontrada';
    END IF;

    SELECT id INTO v_ruta_id FROM ruta WHERE codigo = 'CA-1 Occidente';
    IF v_ruta_id IS NULL THEN
        RAISE EXCEPTION 'Ruta CA-1 Occidente no encontrada';
    END IF;

    -- 2. Crear o obtener turno
    SELECT id INTO v_turno_id FROM turno WHERE fecha = CURRENT_DATE;
    IF v_turno_id IS NULL THEN
        INSERT INTO turno (fecha, estado, creado_por) 
        VALUES (CURRENT_DATE, 'ACTIVO', v_usuario_id) 
        RETURNING id INTO v_turno_id;
        RAISE NOTICE 'Turno creado: %', v_turno_id;
    ELSE
        RAISE NOTICE 'Turno existente: %', v_turno_id;
    END IF;

    -- 3. Crear asignación
    INSERT INTO asignacion_unidad (turno_id, unidad_id, ruta_id, km_inicio, combustible_inicial, combustible_asignado, hora_salida)
    VALUES (v_turno_id, v_unidad_id, v_ruta_id, 150000, 60, 60, '06:00:00')
    RETURNING id INTO v_asignacion_id;
    RAISE NOTICE 'Asignación creada: %', v_asignacion_id;

    -- 4. Asignar tripulación
    INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente)
    VALUES (v_asignacion_id, v_usuario_id, 'PILOTO', true);
    RAISE NOTICE 'Tripulación asignada';

END $$;
