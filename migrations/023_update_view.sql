-- Migration: 023_update_view
-- Description: Recreate v_incidentes_completos to include new columns

DROP VIEW IF EXISTS v_incidentes_completos;

CREATE VIEW v_incidentes_completos AS
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
LEFT JOIN usuario b ON i.brigada_id = b.id -- Corrected: b.id instead of b.usuario_id
JOIN usuario c ON i.creado_por = c.id; -- Corrected: c.id instead of c.usuario_id
