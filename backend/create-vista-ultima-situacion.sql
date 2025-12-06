-- Crear vista v_ultima_situacion_unidad
-- Esta vista muestra la última situación registrada para cada unidad

DROP VIEW IF EXISTS v_ultima_situacion_unidad CASCADE;

CREATE OR REPLACE VIEW v_ultima_situacion_unidad AS
SELECT DISTINCT ON (s.unidad_id)
    s.unidad_id,
    s.id as situacion_id,
    s.uuid as situacion_uuid,
    s.tipo_situacion,
    s.estado,
    s.km,
    s.sentido,
    r.codigo as ruta_codigo,
    r.nombre as ruta_nombre,
    s.latitud,
    s.longitud,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.descripcion,
    s.created_at as situacion_fecha
FROM situacion s
LEFT JOIN ruta r ON s.ruta_id = r.id
WHERE s.unidad_id IS NOT NULL
ORDER BY s.unidad_id, s.created_at DESC;

COMMENT ON VIEW v_ultima_situacion_unidad IS 'Última situación registrada por cada unidad';
