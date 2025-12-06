
-- 1. Eliminar vistas dependientes (CASCADE eliminará las que dependen de estas)
DROP VIEW IF EXISTS v_mi_asignacion_hoy CASCADE;
DROP VIEW IF EXISTS v_turnos_completos CASCADE;
DROP VIEW IF EXISTS v_estadisticas_brigadas CASCADE;
DROP VIEW IF EXISTS v_estadisticas_unidades CASCADE;
DROP VIEW IF EXISTS v_disponibilidad_recursos CASCADE;
DROP VIEW IF EXISTS v_situaciones_con_combustible CASCADE;
DROP VIEW IF EXISTS v_mi_unidad_asignada CASCADE;
DROP VIEW IF EXISTS v_mi_salida_activa CASCADE;
DROP VIEW IF EXISTS v_unidades_en_salida CASCADE;
DROP VIEW IF EXISTS v_incidentes_completos CASCADE;
DROP VIEW IF EXISTS v_actividades_completas CASCADE;
DROP VIEW IF EXISTS v_estado_actual_unidades CASCADE;

-- 2. Modificar columnas de kilometraje
ALTER TABLE asignacion_unidad 
    ALTER COLUMN km_inicio TYPE NUMERIC(10,2),
    ALTER COLUMN km_final TYPE NUMERIC(10,2),
    ALTER COLUMN km_recorridos TYPE NUMERIC(10,2);

-- 3. Recrear vistas

-- v_turnos_completos
CREATE OR REPLACE VIEW v_turnos_completos AS
SELECT
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
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

-- v_mi_asignacion_hoy
CREATE OR REPLACE VIEW v_mi_asignacion_hoy AS
SELECT
    usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.hora_salida,
    a.hora_entrada_estimada,
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

-- v_estadisticas_brigadas
CREATE OR REPLACE VIEW v_estadisticas_brigadas AS
SELECT
    u.id AS usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.sede_id,
    s.nombre AS sede_nombre,
    r.nombre AS rol_nombre,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT t.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_turno,
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,
    MODE() WITHIN GROUP (ORDER BY tt.rol_tripulacion) AS rol_tripulacion_frecuente,
    u.activo
FROM usuario u
INNER JOIN sede s ON u.sede_id = s.id
INNER JOIN rol r ON u.rol_id = r.id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id
LEFT JOIN turno t ON au.turno_id = t.id
WHERE r.nombre = 'BRIGADA'
GROUP BY u.id, u.nombre_completo, u.chapa, u.telefono, u.sede_id, s.nombre, r.nombre, u.activo;

-- v_estadisticas_unidades
CREATE OR REPLACE VIEW v_estadisticas_unidades AS
SELECT
    un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    un.marca,
    un.modelo,
    un.sede_id,
    s.nombre AS sede_nombre,
    un.activa,
    un.combustible_actual,
    un.capacidad_combustible,
    un.odometro_actual,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS turnos_ultimo_mes,
    COUNT(DISTINCT au.id) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '90 days') AS turnos_ultimo_trimestre,
    MAX(t.fecha) AS ultimo_turno_fecha,
    CURRENT_DATE - MAX(t.fecha) AS dias_desde_ultimo_uso,
    MIN(t.fecha) FILTER (WHERE t.fecha >= CURRENT_DATE) AS proximo_turno_fecha,
    AVG(cr.combustible_consumido) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS consumo_promedio_diario,
    AVG(cr.rendimiento_km_litro) FILTER (WHERE cr.created_at >= CURRENT_DATE - INTERVAL '30 days') AS rendimiento_promedio,
    SUM(au.km_recorridos) FILTER (WHERE t.fecha >= CURRENT_DATE - INTERVAL '30 days') AS km_ultimo_mes
FROM unidad un
INNER JOIN sede s ON un.sede_id = s.id
LEFT JOIN asignacion_unidad au ON un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
LEFT JOIN combustible_registro cr ON un.id = cr.unidad_id AND cr.tipo = 'FINAL'
GROUP BY un.id, un.codigo, un.tipo_unidad, un.marca, un.modelo, un.sede_id, s.nombre;

-- v_disponibilidad_recursos
CREATE OR REPLACE VIEW v_disponibilidad_recursos AS
SELECT
    s.id AS sede_id,
    s.nombre AS sede_nombre,
    COUNT(DISTINCT u.id) FILTER (WHERE r.nombre = 'BRIGADA' AND u.activo = TRUE) AS total_brigadas_activas,
    COUNT(DISTINCT tt.usuario_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
        AND r.nombre = 'BRIGADA'
        AND u.activo = TRUE
    ) AS brigadas_en_turno_hoy,
    COUNT(DISTINCT un.id) FILTER (WHERE un.activa = TRUE) AS total_unidades_activas,
    COUNT(DISTINCT au.unidad_id) FILTER (
        WHERE t.fecha = CURRENT_DATE
    ) AS unidades_en_turno_hoy,
    COUNT(DISTINCT u.id) FILTER (
        WHERE r.nombre = 'BRIGADA'
        AND u.activo = TRUE
        AND u.id NOT IN (
            SELECT tt2.usuario_id
            FROM tripulacion_turno tt2
            JOIN asignacion_unidad au2 ON tt2.asignacion_id = au2.id
            JOIN turno t2 ON au2.turno_id = t2.id
            WHERE t2.fecha = CURRENT_DATE
        )
    ) AS brigadas_disponibles_hoy,
    COUNT(DISTINCT un.id) FILTER (
        WHERE un.activa = TRUE
        AND un.id NOT IN (
            SELECT au3.unidad_id
            FROM asignacion_unidad au3
            JOIN turno t3 ON au3.turno_id = t3.id
            WHERE t3.fecha = CURRENT_DATE
        )
    ) AS unidades_disponibles_hoy
FROM sede s
LEFT JOIN usuario u ON s.id = u.sede_id
LEFT JOIN rol r ON u.rol_id = r.id
LEFT JOIN unidad un ON s.id = un.sede_id
LEFT JOIN tripulacion_turno tt ON u.id = tt.usuario_id
LEFT JOIN asignacion_unidad au ON tt.asignacion_id = au.id AND un.id = au.unidad_id
LEFT JOIN turno t ON au.turno_id = t.id
GROUP BY s.id, s.nombre;

-- v_situaciones_con_combustible
CREATE OR REPLACE VIEW v_situaciones_con_combustible AS
SELECT
    s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.created_at,
    LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS combustible_anterior,
    s.combustible - LAG(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS consumo,
    s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS km_recorridos,
    EXTRACT(EPOCH FROM (s.created_at - LAG(s.created_at) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at))) / 60 AS minutos_desde_anterior,
    s.turno_id,
    t.fecha AS turno_fecha
FROM situacion s
LEFT JOIN unidad u ON s.unidad_id = u.id
LEFT JOIN ruta r ON s.ruta_id = r.id
LEFT JOIN turno t ON s.turno_id = t.id
WHERE s.combustible IS NOT NULL
ORDER BY s.unidad_id, s.created_at;

-- v_mi_unidad_asignada
CREATE OR REPLACE VIEW v_mi_unidad_asignada AS
SELECT
    u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,
    bu.fecha_asignacion,
    bu.activo,
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
WHERE bu.activo = TRUE;

-- v_mi_salida_activa
CREATE OR REPLACE VIEW v_mi_salida_activa AS
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    EXTRACT(EPOCH FROM (COALESCE(s.fecha_hora_regreso, NOW()) - s.fecha_hora_salida)) / 3600 AS horas_salida,
    s.ruta_inicial_id AS ruta_id, -- Added ruta_id
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at ASC
        LIMIT 1
    ) AS primera_situacion
FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = TRUE
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id;

-- v_unidades_en_salida
CREATE OR REPLACE VIEW v_unidades_en_salida AS
SELECT
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS salida_id,
    s.fecha_hora_salida,
    EXTRACT(EPOCH FROM (NOW() - s.fecha_hora_salida)) / 3600 AS horas_en_salida,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.tripulacion,
    (
        SELECT COUNT(*)
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
    ) AS total_situaciones,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'km', sit.km,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at DESC
        LIMIT 1
    ) AS ultima_situacion
FROM unidad u
JOIN salida_unidad s ON u.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
ORDER BY s.fecha_hora_salida DESC;

-- v_incidentes_completos
CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT 
    i.*,
    th.nombre as tipo_hecho,
    th.color as tipo_hecho_color,
    th.icono as tipo_hecho_icono,
    sth.nombre as subtipo_hecho,
    r.codigo as ruta_codigo,
    r.nombre as ruta_nombre,
    u.codigo as unidad_codigo,
    b.nombre_completo as brigada_nombre,
    c.nombre_completo as creado_por_nombre
FROM incidente i
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN subtipo_hecho sth ON i.subtipo_hecho_id = sth.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN usuario b ON i.brigada_id = b.id
JOIN usuario c ON i.creado_por = c.id;

-- v_actividades_completas
CREATE OR REPLACE VIEW v_actividades_completas AS
SELECT
    a.id,
    a.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    ta.nombre AS tipo_actividad,
    ta.color AS tipo_actividad_color,
    a.hora_inicio,
    a.hora_fin,
    EXTRACT(EPOCH FROM (COALESCE(a.hora_fin, NOW()) - a.hora_inicio))/60 AS duracion_min,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km,
    a.sentido,
    a.incidente_id,
    i.numero_reporte AS incidente_numero,
    usr.nombre_completo AS registrado_por_nombre,
    a.observaciones,
    a.created_at
FROM actividad_unidad a
JOIN unidad u ON a.unidad_id = u.id
JOIN sede s ON u.sede_id = s.id
JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
JOIN usuario usr ON a.registrado_por = usr.id;

-- v_estado_actual_unidades
CREATE OR REPLACE VIEW v_estado_actual_unidades AS
SELECT DISTINCT ON (u.id)
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    u.activa,
    ta.nombre AS actividad_actual,
    ta.color AS actividad_color,
    a.hora_inicio AS desde,
    r.codigo AS ruta_codigo,
    a.km,
    a.sentido,
    a.observaciones,
    i.numero_reporte AS incidente_numero,
    i.estado AS incidente_estado
FROM unidad u
JOIN sede s ON u.sede_id = s.id
LEFT JOIN LATERAL (
    SELECT *
    FROM actividad_unidad au
    WHERE au.unidad_id = u.id
      AND au.hora_fin IS NULL
    ORDER BY au.hora_inicio DESC
    LIMIT 1
) a ON TRUE
LEFT JOIN tipo_actividad ta ON a.tipo_actividad_id = ta.id
LEFT JOIN ruta r ON a.ruta_id = r.id
LEFT JOIN incidente i ON a.incidente_id = i.id
ORDER BY u.id;
