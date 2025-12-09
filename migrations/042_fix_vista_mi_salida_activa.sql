-- Migracion 042: Corregir vista v_mi_salida_activa
-- Problema: La vista solo consideraba asignaciones permanentes (brigada_unidad)
-- Solucion: Tambien considerar asignaciones de turno (tripulacion_turno)
-- Fecha: 2025-12-09

DROP VIEW IF EXISTS v_mi_salida_activa;

CREATE VIEW v_mi_salida_activa AS
-- Salidas activas via asignacion permanente (brigada_unidad)
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    EXTRACT(epoch FROM COALESCE(s.fecha_hora_regreso, now()) - s.fecha_hora_salida) / 3600 AS horas_salida,
    s.ruta_inicial_id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    'PERMANENTE' AS tipo_asignacion,
    bu.rol_tripulacion AS mi_rol,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at
        LIMIT 1
    ) AS primera_situacion
FROM usuario u
JOIN brigada_unidad bu ON u.id = bu.brigada_id AND bu.activo = true
JOIN unidad un ON bu.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id

UNION ALL

-- Salidas activas via asignacion de turno (tripulacion_turno)
SELECT
    u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    EXTRACT(epoch FROM COALESCE(s.fecha_hora_regreso, now()) - s.fecha_hora_salida) / 3600 AS horas_salida,
    s.ruta_inicial_id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    'TURNO' AS tipo_asignacion,
    tt.rol_tripulacion AS mi_rol,
    (
        SELECT json_build_object(
            'id', sit.id,
            'tipo', sit.tipo_situacion,
            'fecha_hora', sit.created_at
        )
        FROM situacion sit
        WHERE sit.salida_unidad_id = s.id
        ORDER BY sit.created_at
        LIMIT 1
    ) AS primera_situacion
FROM usuario u
JOIN tripulacion_turno tt ON u.id = tt.usuario_id
JOIN asignacion_unidad au ON tt.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
JOIN unidad un ON au.unidad_id = un.id
JOIN salida_unidad s ON un.id = s.unidad_id AND s.estado = 'EN_SALIDA'
LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
WHERE t.estado IN ('PLANIFICADO', 'ACTIVO')
  -- Solo salidas de hoy (para evitar duplicados con salidas viejas)
  AND DATE(s.fecha_hora_salida) = CURRENT_DATE;

COMMENT ON VIEW v_mi_salida_activa IS 'Muestra la salida activa de un brigada. Considera tanto asignaciones permanentes como de turno.';

-- Confirmar
SELECT 'Migracion 042 completada: v_mi_salida_activa ahora considera asignaciones de turno' AS resultado;
