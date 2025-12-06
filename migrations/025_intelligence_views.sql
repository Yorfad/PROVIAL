-- ========================================
-- Migración 025: Vistas Materializadas de Inteligencia
-- ========================================
-- Objetivo: Crear vistas materializadas para análisis y alertas inteligentes

-- ========================================
-- 1. VEHÍCULOS REINCIDENTES
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_vehiculos_reincidentes AS
SELECT
    v.id,
    v.placa,
    v.es_extranjero,
    tv.nombre as tipo_vehiculo,
    m.nombre as marca,
    v.color,
    v.total_incidentes,
    v.primer_incidente,
    v.ultimo_incidente,
    -- Calcular días desde el primer incidente
    CASE
        WHEN v.primer_incidente IS NOT NULL
        THEN EXTRACT(DAY FROM (NOW() - v.primer_incidente))::INTEGER
        ELSE NULL
    END as dias_desde_primer_incidente,
    -- Calcular días desde el último incidente
    CASE
        WHEN v.ultimo_incidente IS NOT NULL
        THEN EXTRACT(DAY FROM (NOW() - v.ultimo_incidente))::INTEGER
        ELSE NULL
    END as dias_desde_ultimo_incidente,
    -- Calcular frecuencia de incidentes (incidentes por mes)
    CASE
        WHEN v.primer_incidente IS NOT NULL AND v.ultimo_incidente IS NOT NULL
        THEN v.total_incidentes::NUMERIC / GREATEST(1, EXTRACT(EPOCH FROM (v.ultimo_incidente - v.primer_incidente)) / (30 * 24 * 60 * 60))
        ELSE 0
    END as frecuencia_mensual,
    -- Nivel de riesgo (1-5)
    CASE
        WHEN v.total_incidentes >= 5 THEN 5
        WHEN v.total_incidentes >= 4 THEN 4
        WHEN v.total_incidentes >= 3 THEN 3
        WHEN v.total_incidentes >= 2 THEN 2
        ELSE 1
    END as nivel_riesgo
FROM vehiculo v
LEFT JOIN tipo_vehiculo tv ON v.tipo_vehiculo_id = tv.id
LEFT JOIN marca_vehiculo m ON v.marca_id = m.id
WHERE v.total_incidentes >= 2 -- Solo vehículos con 2+ incidentes
ORDER BY v.total_incidentes DESC, v.ultimo_incidente DESC;

CREATE UNIQUE INDEX ON mv_vehiculos_reincidentes (id);
CREATE INDEX ON mv_vehiculos_reincidentes (placa);
CREATE INDEX ON mv_vehiculos_reincidentes (nivel_riesgo DESC);

COMMENT ON MATERIALIZED VIEW mv_vehiculos_reincidentes IS 'Vehículos con múltiples incidentes y su nivel de riesgo';

-- ========================================
-- 2. PILOTOS PROBLEMÁTICOS
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_pilotos_problematicos AS
SELECT
    p.id,
    p.nombre,
    p.licencia_tipo,
    p.licencia_numero,
    p.licencia_vencimiento,
    p.total_incidentes,
    p.total_sanciones,
    p.primer_incidente,
    p.ultimo_incidente,
    -- Calcular edad aproximada
    CASE
        WHEN p.fecha_nacimiento IS NOT NULL
        THEN EXTRACT(YEAR FROM AGE(p.fecha_nacimiento))
        ELSE NULL
    END as edad,
    -- Verificar si la licencia está vencida
    CASE
        WHEN p.licencia_vencimiento IS NOT NULL AND p.licencia_vencimiento < NOW()
        THEN true
        ELSE false
    END as licencia_vencida,
    -- Días hasta vencimiento (negativo si ya venció)
    CASE
        WHEN p.licencia_vencimiento IS NOT NULL
        THEN (p.licencia_vencimiento - NOW()::DATE)
        ELSE NULL
    END as dias_hasta_vencimiento,
    -- Nivel de riesgo combinado (1-5)
    CASE
        WHEN p.total_sanciones >= 5 OR p.total_incidentes >= 5 THEN 5
        WHEN p.total_sanciones >= 3 OR p.total_incidentes >= 4 THEN 4
        WHEN p.total_sanciones >= 2 OR p.total_incidentes >= 3 THEN 3
        WHEN p.total_sanciones >= 1 OR p.total_incidentes >= 2 THEN 2
        ELSE 1
    END as nivel_riesgo
FROM piloto p
WHERE p.total_incidentes >= 1 OR p.total_sanciones >= 1
ORDER BY (p.total_incidentes + p.total_sanciones) DESC, p.ultimo_incidente DESC;

CREATE UNIQUE INDEX ON mv_pilotos_problematicos (id);
CREATE INDEX ON mv_pilotos_problematicos (licencia_numero);
CREATE INDEX ON mv_pilotos_problematicos (nivel_riesgo DESC);
CREATE INDEX ON mv_pilotos_problematicos (licencia_vencida) WHERE licencia_vencida = true;

COMMENT ON MATERIALIZED VIEW mv_pilotos_problematicos IS 'Pilotos con incidentes/sanciones y su nivel de riesgo';

-- ========================================
-- 3. PUNTOS CALIENTES (HOTSPOTS)
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_puntos_calientes AS
SELECT
    -- Identificador compuesto
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as id,

    -- Ubicación
    COALESCE(r.codigo, 'SIN_RUTA') as ruta_codigo,
    COALESCE(r.nombre, 'Sin ruta asignada') as ruta_nombre,
    i.municipio_id as municipio_codigo,
    m.nombre as municipio_nombre,
    i.km as kilometro,

    -- Estadísticas
    COUNT(*) as total_incidentes,
    COUNT(*) as total_accidentes, -- Todos los incidentes son accidentes en esta tabla
    0 as total_asistencias, -- No hay campo tipo en incidente
    0 as total_emergencias, -- No hay campo tipo en incidente

    -- Heridos y fallecidos
    COALESCE(SUM(i.cantidad_heridos), 0) as total_heridos,
    COALESCE(SUM(i.cantidad_fallecidos), 0) as total_fallecidos,

    -- Fechas
    MIN(i.created_at) as primer_incidente,
    MAX(i.created_at) as ultimo_incidente,

    -- Frecuencia (incidentes por mes)
    COUNT(*)::NUMERIC / GREATEST(1, EXTRACT(EPOCH FROM (MAX(i.created_at) - MIN(i.created_at))) / (30 * 24 * 60 * 60)) as frecuencia_mensual,

    -- Nivel de peligrosidad (1-5)
    CASE
        WHEN COUNT(*) >= 10 OR SUM(i.cantidad_fallecidos) >= 3 THEN 5
        WHEN COUNT(*) >= 7 OR SUM(i.cantidad_fallecidos) >= 2 THEN 4
        WHEN COUNT(*) >= 5 OR SUM(i.cantidad_heridos) >= 5 THEN 3
        WHEN COUNT(*) >= 3 OR SUM(i.cantidad_heridos) >= 2 THEN 2
        ELSE 1
    END as nivel_peligrosidad,

    -- Coordenadas promedio (para mapas)
    AVG(i.latitud) as latitud_promedio,
    AVG(i.longitud) as longitud_promedio

FROM incidente i
LEFT JOIN ruta r ON i.ruta_id = r.id
LEFT JOIN municipio m ON i.municipio_id = m.id
WHERE i.estado IN ('REGISTRADO', 'CERRADO') -- Estados del incidente
GROUP BY r.codigo, r.nombre, i.municipio_id, m.nombre, i.km
HAVING COUNT(*) >= 2 -- Solo puntos con 2+ incidentes
ORDER BY total_incidentes DESC, total_fallecidos DESC, total_heridos DESC;

CREATE UNIQUE INDEX ON mv_puntos_calientes (id);
CREATE INDEX ON mv_puntos_calientes (ruta_codigo, kilometro);
CREATE INDEX ON mv_puntos_calientes (nivel_peligrosidad DESC);
CREATE INDEX ON mv_puntos_calientes (municipio_codigo);

COMMENT ON MATERIALIZED VIEW mv_puntos_calientes IS 'Puntos geográficos con alta concentración de incidentes';

-- ========================================
-- 4. TENDENCIAS TEMPORALES
-- ========================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tendencias_temporales AS
SELECT
    -- Fecha
    DATE(i.created_at) as fecha,
    EXTRACT(YEAR FROM i.created_at)::INTEGER as anio,
    EXTRACT(MONTH FROM i.created_at)::INTEGER as mes,
    EXTRACT(DOW FROM i.created_at)::INTEGER as dia_semana, -- 0=Domingo, 6=Sábado
    EXTRACT(HOUR FROM i.created_at)::INTEGER as hora,

    -- Nombre del día
    CASE EXTRACT(DOW FROM i.created_at)::INTEGER
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END as nombre_dia,

    -- Tipo de día
    CASE
        WHEN EXTRACT(DOW FROM i.created_at)::INTEGER IN (0, 6) THEN 'Fin de semana'
        ELSE 'Entre semana'
    END as tipo_dia,

    -- Franja horaria
    CASE
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 0 AND 5 THEN 'Madrugada (00:00-05:59)'
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 6 AND 11 THEN 'Mañana (06:00-11:59)'
        WHEN EXTRACT(HOUR FROM i.created_at)::INTEGER BETWEEN 12 AND 17 THEN 'Tarde (12:00-17:59)'
        ELSE 'Noche (18:00-23:59)'
    END as franja_horaria,

    -- Estadísticas
    COUNT(*) as total_incidentes,
    COUNT(*) as total_accidentes, -- Todos son accidentes
    0 as total_asistencias, -- No hay campo tipo
    0 as total_emergencias, -- No hay campo tipo

    COALESCE(SUM(i.cantidad_heridos), 0) as total_heridos,
    COALESCE(SUM(i.cantidad_fallecidos), 0) as total_fallecidos

FROM incidente i
WHERE i.estado IN ('REGISTRADO', 'CERRADO')
GROUP BY fecha, anio, mes, dia_semana, hora, nombre_dia, tipo_dia, franja_horaria
ORDER BY fecha DESC, hora DESC;

CREATE UNIQUE INDEX ON mv_tendencias_temporales (fecha, hora);
CREATE INDEX ON mv_tendencias_temporales (fecha DESC);
CREATE INDEX ON mv_tendencias_temporales (anio, mes);
CREATE INDEX ON mv_tendencias_temporales (dia_semana);
CREATE INDEX ON mv_tendencias_temporales (hora);
CREATE INDEX ON mv_tendencias_temporales (franja_horaria);

COMMENT ON MATERIALIZED VIEW mv_tendencias_temporales IS 'Análisis temporal de incidentes por fecha, hora y día de la semana';

-- ========================================
-- 5. FUNCIÓN PARA REFRESCAR TODAS LAS VISTAS
-- ========================================

CREATE OR REPLACE FUNCTION refresh_intelligence_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vehiculos_reincidentes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_pilotos_problematicos;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_puntos_calientes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tendencias_temporales;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_intelligence_views IS 'Refresca todas las vistas materializadas de inteligencia';

-- ========================================
-- 6. TRIGGER PARA AUTO-REFRESH (OPCIONAL)
-- ========================================

-- Crear tabla para controlar cuando refrescar
CREATE TABLE IF NOT EXISTS intelligence_refresh_log (
    id SERIAL PRIMARY KEY,
    view_name VARCHAR(100) NOT NULL,
    refreshed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_ms INTEGER,
    rows_affected INTEGER
);

COMMENT ON TABLE intelligence_refresh_log IS 'Log de refrescos de vistas materializadas';

-- ========================================
-- NOTAS:
-- ========================================
-- - Las vistas materializadas se deben refrescar periódicamente (ej: cada hora)
-- - Se puede usar un cron job o scheduler para llamar refresh_intelligence_views()
-- - El índice UNIQUE permite usar REFRESH MATERIALIZED VIEW CONCURRENTLY (sin bloquear lecturas)
