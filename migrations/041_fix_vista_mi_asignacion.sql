-- Migracion 041: Corregir vista v_mi_asignacion_hoy
-- Problema: Faltaba el campo ruta_id que es necesario para iniciar salida
-- Fecha: 2025-12-09

DROP VIEW IF EXISTS v_mi_asignacion_hoy;

CREATE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.id AS ruta_id,  -- AGREGADO: ID de la ruta para iniciar salida
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    CASE
        WHEN a.km_inicio IS NOT NULL AND a.km_final IS NOT NULL
            THEN 'Km ' || a.km_inicio || ' - Km ' || a.km_final
        WHEN a.km_inicio IS NOT NULL THEN 'Desde Km ' || a.km_inicio
        WHEN a.km_final IS NOT NULL THEN 'Hasta Km ' || a.km_final
        ELSE NULL
    END AS recorrido_permitido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    -- Calcular dias hasta la asignacion
    CASE
        WHEN t.fecha = CURRENT_DATE THEN 0
        ELSE t.fecha - CURRENT_DATE
    END AS dias_para_salida,
    -- Companeros de brigada
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', u2.id,
                'nombre', u2.nombre_completo,
                'chapa', u2.chapa,
                'rol', tc2.rol_tripulacion,
                'telefono', u2.telefono
            ) ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPANANTE' THEN 3
                    ELSE 4
                END
        )
        FROM tripulacion_turno tc2
        JOIN usuario u2 ON tc2.usuario_id = u2.id
        WHERE tc2.asignacion_id = a.id
        AND tc2.usuario_id <> usr.id
    ) AS companeros
FROM usuario usr
JOIN tripulacion_turno tc ON usr.id = tc.usuario_id
JOIN asignacion_unidad a ON tc.asignacion_id = a.id
JOIN turno t ON a.turno_id = t.id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE
    -- Mostrar asignaciones de hoy en adelante (no pasadas)
    (t.fecha >= CURRENT_DATE OR (t.fecha_fin IS NOT NULL AND t.fecha_fin >= CURRENT_DATE))
    -- Solo turnos planificados o activos
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
    -- No mostrar asignaciones que ya finalizaron (tienen hora_entrada_real)
    AND a.hora_entrada_real IS NULL;

COMMENT ON VIEW v_mi_asignacion_hoy IS 'Muestra la proxima asignacion del brigada (hoy o futura). Incluye ruta_id, companeros y detalles.';

-- =============================================
-- 2. AGREGAR ruta_id A v_asignaciones_pendientes
-- =============================================

DROP VIEW IF EXISTS v_asignaciones_pendientes;

CREATE VIEW v_asignaciones_pendientes AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    a.id AS id,  -- Alias para compatibilidad con frontend
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.id AS ruta_id,  -- AGREGADO: ID de la ruta para edicion
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    a.acciones,
    CASE
        WHEN t.fecha = CURRENT_DATE THEN 'HOY'
        WHEN t.fecha = CURRENT_DATE + 1 THEN 'MANANA'
        ELSE t.fecha::TEXT
    END AS dia_salida,
    (
        SELECT json_agg(
            json_build_object(
                'usuario_id', usr.id,
                'nombre_completo', usr.nombre_completo,
                'nombre', usr.nombre_completo,
                'chapa', usr.chapa,
                'rol_tripulacion', tc.rol_tripulacion,
                'rol', tc.rol_tripulacion
            ) ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPANANTE' THEN 3
                    ELSE 4
                END
        )
        FROM tripulacion_turno tc
        JOIN usuario usr ON tc.usuario_id = usr.id
        WHERE tc.asignacion_id = a.id
    ) AS tripulacion
FROM turno t
JOIN asignacion_unidad a ON t.id = a.turno_id
JOIN unidad u ON a.unidad_id = u.id
LEFT JOIN ruta r ON a.ruta_id = r.id
WHERE
    (t.fecha >= CURRENT_DATE OR (t.fecha_fin IS NOT NULL AND t.fecha_fin >= CURRENT_DATE))
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
ORDER BY t.fecha, a.hora_salida;

COMMENT ON VIEW v_asignaciones_pendientes IS 'Lista de asignaciones pendientes para operaciones (hoy y futuras). Incluye ruta_id para edicion.';

-- Confirmar
SELECT 'Migracion 041 completada: agregado ruta_id a vistas' AS resultado;
