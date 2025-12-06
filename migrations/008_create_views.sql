-- Migración 008: Vistas y vistas materializadas

-- ========================================
-- VISTA: Incidentes con información completa
-- ========================================

CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT
    i.id,
    i.uuid,
    i.numero_reporte,
    i.origen,
    i.estado,

    -- Tipo de hecho
    th.nombre AS tipo_hecho,
    sth.nombre AS subtipo_hecho,
    th.color AS tipo_hecho_color,
    th.icono AS tipo_hecho_icono,

    -- Ubicación
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    i.km,
    i.sentido,
    i.referencia_ubicacion,
    i.latitud,
    i.longitud,

    -- Unidad y brigada
    u.codigo AS unidad_codigo,
    b.codigo AS brigada_codigo,
    b.nombre AS brigada_nombre,
    s.nombre AS sede_nombre,

    -- Tiempos
    i.fecha_hora_aviso,
    i.fecha_hora_asignacion,
    i.fecha_hora_llegada,
    i.fecha_hora_estabilizacion,
    i.fecha_hora_finalizacion,

    -- Tiempo de respuesta (en minutos)
    EXTRACT(EPOCH FROM (i.fecha_hora_llegada - i.fecha_hora_aviso))/60 AS tiempo_respuesta_min,
    EXTRACT(EPOCH FROM (i.fecha_hora_finalizacion - i.fecha_hora_llegada))/60 AS tiempo_atencion_min,

    -- Víctimas
    i.hay_heridos,
    i.cantidad_heridos,
    i.hay_fallecidos,
    i.cantidad_fallecidos,

    -- Recursos
    i.requiere_bomberos,
    i.requiere_pnc,
    i.requiere_ambulancia,

    -- Conteo de vehículos
    (SELECT COUNT(*) FROM vehiculo_incidente vi WHERE vi.incidente_id = i.id) AS total_vehiculos,

    -- Obstrucción
    o.descripcion_generada AS obstruccion_descripcion,

    -- Usuario creador
    usr.nombre_completo AS creado_por_nombre,

    -- Timestamps
    i.created_at,
    i.updated_at

FROM incidente i
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
LEFT JOIN subtipo_hecho sth ON i.subtipo_hecho_id = sth.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN brigada b ON i.brigada_id = b.id
LEFT JOIN sede s ON u.sede_id = s.id
LEFT JOIN obstruccion_incidente o ON i.id = o.incidente_id
JOIN usuario usr ON i.creado_por = usr.id;

COMMENT ON VIEW v_incidentes_completos IS 'Vista completa de incidentes con todos los datos relacionados';

-- ========================================
-- VISTA: Actividades de unidades con información completa
-- ========================================

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

    -- Ubicación
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km,
    a.sentido,

    -- Incidente asociado
    a.incidente_id,
    i.numero_reporte AS incidente_numero,

    -- Usuario
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

COMMENT ON VIEW v_actividades_completas IS 'Vista completa de actividades con información relacionada';

-- ========================================
-- VISTA MATERIALIZADA: Estadísticas diarias
-- ========================================

CREATE MATERIALIZED VIEW mv_estadisticas_diarias AS
SELECT
    DATE(i.fecha_hora_aviso) AS fecha,
    i.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    i.tipo_hecho_id,
    th.nombre AS tipo_hecho,
    i.origen,
    i.estado,

    COUNT(*) AS total_incidentes,
    SUM(i.cantidad_heridos) AS total_heridos,
    SUM(i.cantidad_fallecidos) AS total_fallecidos,

    -- Tiempos promedio
    AVG(EXTRACT(EPOCH FROM (i.fecha_hora_llegada - i.fecha_hora_aviso))/60) AS tiempo_respuesta_promedio_min,
    AVG(EXTRACT(EPOCH FROM (i.fecha_hora_finalizacion - i.fecha_hora_llegada))/60) AS tiempo_atencion_promedio_min,

    -- Contadores por estado
    COUNT(*) FILTER (WHERE i.estado = 'CERRADO') AS total_cerrados,
    COUNT(*) FILTER (WHERE i.estado = 'NO_ATENDIDO') AS total_no_atendidos,

    -- Contadores por víctimas
    COUNT(*) FILTER (WHERE i.hay_heridos = TRUE) AS incidentes_con_heridos,
    COUNT(*) FILTER (WHERE i.hay_fallecidos = TRUE) AS incidentes_con_fallecidos

FROM incidente i
JOIN ruta r ON i.ruta_id = r.id
JOIN tipo_hecho th ON i.tipo_hecho_id = th.id
WHERE i.fecha_hora_aviso >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY
    DATE(i.fecha_hora_aviso),
    i.ruta_id, r.codigo, r.nombre,
    i.tipo_hecho_id, th.nombre,
    i.origen,
    i.estado;

-- Índice único para refresh concurrente
CREATE UNIQUE INDEX idx_mv_estadisticas_diarias
ON mv_estadisticas_diarias (fecha, ruta_id, tipo_hecho_id, origen, estado);

-- Índices adicionales para consultas frecuentes
CREATE INDEX idx_mv_estadisticas_fecha ON mv_estadisticas_diarias(fecha DESC);
CREATE INDEX idx_mv_estadisticas_ruta ON mv_estadisticas_diarias(ruta_id);

COMMENT ON MATERIALIZED VIEW mv_estadisticas_diarias IS 'Estadísticas diarias de incidentes (últimos 90 días). Refrescar nightly.';

-- ========================================
-- VISTA MATERIALIZADA: Métricas de no atendidos
-- ========================================

CREATE MATERIALIZED VIEW mv_no_atendidos_por_motivo AS
SELECT
    DATE_TRUNC('month', i.fecha_hora_aviso) AS mes,
    m.id AS motivo_id,
    m.nombre AS motivo,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.id AS sede_id,
    s.nombre AS sede_nombre,

    COUNT(*) AS total,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', i.fecha_hora_aviso)),
        2
    ) AS porcentaje_del_mes

FROM incidente i
JOIN incidente_no_atendido ina ON i.id = ina.incidente_id
JOIN motivo_no_atendido m ON ina.motivo_id = m.id
JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN unidad u ON i.unidad_id = u.id
LEFT JOIN sede s ON u.sede_id = s.id
WHERE i.estado = 'NO_ATENDIDO'
  AND i.fecha_hora_aviso >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY
    DATE_TRUNC('month', i.fecha_hora_aviso),
    m.id, m.nombre,
    r.id, r.codigo, r.nombre,
    s.id, s.nombre;

CREATE UNIQUE INDEX idx_mv_no_atendidos
ON mv_no_atendidos_por_motivo (mes, motivo_id, COALESCE(ruta_id, 0), COALESCE(sede_id, 0));

COMMENT ON MATERIALIZED VIEW mv_no_atendidos_por_motivo IS 'Métricas de incidentes no atendidos por motivo (últimos 12 meses)';

-- ========================================
-- VISTA: Estado actual de unidades (última actividad)
-- ========================================

CREATE OR REPLACE VIEW v_estado_actual_unidades AS
SELECT DISTINCT ON (u.id)
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    u.activa,

    -- Última actividad
    ta.nombre AS actividad_actual,
    ta.color AS actividad_color,
    a.hora_inicio AS desde,
    r.codigo AS ruta_codigo,
    a.km,
    a.sentido,
    a.observaciones,

    -- Incidente asociado (si aplica)
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

COMMENT ON VIEW v_estado_actual_unidades IS 'Estado actual de todas las unidades (actividad activa)';
