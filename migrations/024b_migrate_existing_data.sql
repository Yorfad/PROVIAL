-- ========================================
-- Migración 024b: Migración de Datos Existentes
-- ========================================
-- Objetivo: Migrar datos de vehiculo_incidente a las nuevas tablas normalizadas

-- ========================================
-- 1. MIGRAR VEHÍCULOS
-- ========================================

-- Insertar vehículos únicos desde vehiculo_incidente
INSERT INTO vehiculo (placa, es_extranjero, tipo_vehiculo_id, color, marca_id, cargado, tipo_carga)
SELECT DISTINCT ON (placa)
    placa,
    FALSE as es_extranjero, -- Columna no existe en vehiculo_incidente, usar FALSE por defecto
    tipo_vehiculo_id,
    color,
    marca_id,
    cargado,
    carga_tipo as tipo_carga -- La columna se llama carga_tipo en vehiculo_incidente
FROM vehiculo_incidente
WHERE placa IS NOT NULL AND placa != ''
ON CONFLICT (placa) DO NOTHING;

-- Actualizar contador de incidentes y fechas para vehículos migrados
UPDATE vehiculo v SET
    total_incidentes = (
        SELECT COUNT(DISTINCT vi.incidente_id)
        FROM vehiculo_incidente vi
        WHERE vi.placa = v.placa
    ),
    primer_incidente = (
        SELECT MIN(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE vi.placa = v.placa
    ),
    ultimo_incidente = (
        SELECT MAX(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE vi.placa = v.placa
    );

-- ========================================
-- 2. MIGRAR PILOTOS
-- ========================================

-- Insertar pilotos únicos desde vehiculo_incidente
INSERT INTO piloto (
    nombre,
    licencia_tipo,
    licencia_numero,
    licencia_vencimiento,
    licencia_antiguedad,
    fecha_nacimiento,
    etnia
)
SELECT DISTINCT ON (licencia_numero)
    nombre_piloto,
    licencia_tipo,
    CAST(licencia_numero AS BIGINT), -- Convertir a BIGINT
    licencia_vencimiento,
    licencia_antiguedad,
    piloto_nacimiento as fecha_nacimiento, -- Columna correcta
    piloto_etnia as etnia -- Columna correcta
FROM vehiculo_incidente
WHERE licencia_numero IS NOT NULL
ON CONFLICT (licencia_numero) DO NOTHING;

-- Actualizar contador de incidentes para pilotos migrados
UPDATE piloto p SET
    total_incidentes = (
        SELECT COUNT(DISTINCT vi.incidente_id)
        FROM vehiculo_incidente vi
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    ),
    primer_incidente = (
        SELECT MIN(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    ),
    ultimo_incidente = (
        SELECT MAX(i.created_at)
        FROM vehiculo_incidente vi
        JOIN incidente i ON vi.incidente_id = i.id
        WHERE CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
    );

-- ========================================
-- 3. MIGRAR TARJETAS DE CIRCULACIÓN
-- ========================================

-- Insertar TCs desde vehiculo_incidente (solo si hay datos)
INSERT INTO tarjeta_circulacion (
    vehiculo_id,
    numero,
    nit,
    direccion_propietario,
    nombre_propietario,
    modelo
)
SELECT DISTINCT ON (v.id, vi.tarjeta_circulacion)
    v.id,
    CAST(vi.tarjeta_circulacion AS BIGINT) as numero, -- Columna correcta
    CASE
        WHEN vi.nit ~ '^[0-9]+$' THEN CAST(vi.nit AS BIGINT)
        ELSE NULL
    END as nit, -- nit es VARCHAR, convertir solo si es numérico
    vi.direccion_propietario,
    vi.nombre_propietario,
    vi.anio as modelo -- anio es el año del modelo
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.tarjeta_circulacion IS NOT NULL AND vi.tarjeta_circulacion ~ '^[0-9]+$';

-- ========================================
-- 4. MIGRAR CONTENEDORES
-- ========================================

-- Insertar contenedores desde vehiculo_incidente (datos en JSONB)
INSERT INTO contenedor (
    vehiculo_id,
    numero_contenedor,
    linea_naviera,
    tipo_contenedor
)
SELECT DISTINCT ON (v.id, vi.contenedor_detalle->>'numero_contenedor')
    v.id,
    vi.contenedor_detalle->>'numero_contenedor' as numero_contenedor,
    vi.contenedor_detalle->>'linea_naviera' as linea_naviera,
    vi.contenedor_detalle->>'tipo' as tipo_contenedor
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.contenedor = TRUE
  AND vi.contenedor_detalle IS NOT NULL
  AND vi.contenedor_detalle->>'numero_contenedor' IS NOT NULL;

-- ========================================
-- 5. MIGRAR BUSES
-- ========================================

-- Insertar buses desde vehiculo_incidente (datos en JSONB)
INSERT INTO bus (
    vehiculo_id,
    empresa,
    ruta_bus,
    numero_unidad,
    capacidad_pasajeros
)
SELECT DISTINCT ON (v.id)
    v.id,
    vi.bus_detalle->>'empresa' as empresa,
    vi.bus_detalle->>'ruta' as ruta_bus,
    vi.bus_detalle->>'numero_unidad' as numero_unidad,
    CASE
        WHEN vi.bus_detalle->>'capacidad_pasajeros' ~ '^[0-9]+$'
        THEN CAST(vi.bus_detalle->>'capacidad_pasajeros' AS INTEGER)
        ELSE NULL
    END as capacidad_pasajeros
FROM vehiculo_incidente vi
JOIN vehiculo v ON vi.placa = v.placa
WHERE vi.bus_extraurbano = TRUE
  AND vi.bus_detalle IS NOT NULL
  AND vi.bus_detalle->>'empresa' IS NOT NULL;

-- ========================================
-- 6. MIGRAR ASEGURADORAS
-- ========================================

-- NOTA: No hay columna 'aseguradora' en vehiculo_incidente
-- Esta sección se puede usar cuando se agregue esa información
-- Por ahora, dejamos las tablas vacías

-- Insertar aseguradoras únicas desde vehiculo_incidente (SKIP - no existe la columna)
-- INSERT INTO aseguradora (nombre)
-- SELECT DISTINCT aseguradora
-- FROM vehiculo_incidente
-- WHERE aseguradora IS NOT NULL
--   AND aseguradora != ''
-- ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- 7. MIGRAR GRÚAS
-- ========================================

-- Insertar grúas únicas desde grua_involucrada
INSERT INTO grua (
    nombre,
    placa,
    telefono,
    empresa,
    nit
)
SELECT DISTINCT ON (piloto, empresa, placa)
    COALESCE(piloto, 'Grúa ' || placa, 'Grúa sin nombre') as nombre,
    placa,
    NULL as telefono, -- No existe en grua_involucrada
    empresa,
    NULL as nit -- No existe en grua_involucrada
FROM grua_involucrada
WHERE placa IS NOT NULL OR piloto IS NOT NULL;

-- Actualizar contador de servicios para grúas
UPDATE grua g SET
    total_servicios = (
        SELECT COUNT(*)
        FROM grua_involucrada gi
        WHERE (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
          AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
    ),
    ultima_vez_usado = (
        SELECT MAX(i.created_at)
        FROM grua_involucrada gi
        JOIN incidente i ON gi.incidente_id = i.id
        WHERE (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
          AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
    );

-- ========================================
-- 8. MIGRAR RELACIONES INCIDENTE-VEHICULO
-- ========================================

-- Insertar relaciones desde vehiculo_incidente
INSERT INTO incidente_vehiculo (
    incidente_id,
    vehiculo_id,
    piloto_id,
    estado_piloto,
    personas_asistidas,
    aseguradora_id,
    numero_poliza
)
SELECT
    vi.incidente_id,
    v.id AS vehiculo_id,
    p.id AS piloto_id,
    vi.estado_piloto,
    vi.personas_asistidas,
    NULL as aseguradora_id, -- No hay datos de aseguradora en vehiculo_incidente
    NULL as numero_poliza -- No hay datos de poliza en vehiculo_incidente
FROM vehiculo_incidente vi
LEFT JOIN vehiculo v ON vi.placa = v.placa
LEFT JOIN piloto p ON CAST(vi.licencia_numero AS BIGINT) = p.licencia_numero
WHERE v.id IS NOT NULL; -- Solo migrar si el vehículo existe

-- ========================================
-- 9. MIGRAR RELACIONES INCIDENTE-GRÚA
-- ========================================

-- Insertar relaciones desde grua_involucrada
INSERT INTO incidente_grua (
    incidente_id,
    grua_id,
    hora_llamada,
    hora_llegada,
    destino,
    costo
)
SELECT
    gi.incidente_id,
    g.id AS grua_id,
    NULL as hora_llamada, -- No existe en grua_involucrada
    NULL as hora_llegada, -- No existe en grua_involucrada
    gi.traslado_a as destino,
    NULL as costo -- No existe en grua_involucrada
FROM grua_involucrada gi
LEFT JOIN grua g ON (gi.placa = g.placa OR (gi.placa IS NULL AND g.placa IS NULL))
  AND (gi.empresa = g.empresa OR (gi.empresa IS NULL AND g.empresa IS NULL))
WHERE g.id IS NOT NULL AND gi.traslado = TRUE; -- Solo migrar si la grúa existe y hubo traslado

-- ========================================
-- 10. VERIFICACIÓN DE LA MIGRACIÓN
-- ========================================

-- Mostrar resumen de la migración
SELECT
    'Vehículos migrados' AS tabla,
    COUNT(*) AS total
FROM vehiculo

UNION ALL

SELECT
    'Pilotos migrados' AS tabla,
    COUNT(*) AS total
FROM piloto

UNION ALL

SELECT
    'Tarjetas circulación migradas' AS tabla,
    COUNT(*) AS total
FROM tarjeta_circulacion

UNION ALL

SELECT
    'Contenedores migrados' AS tabla,
    COUNT(*) AS total
FROM contenedor

UNION ALL

SELECT
    'Buses migrados' AS tabla,
    COUNT(*) AS total
FROM bus

UNION ALL

SELECT
    'Aseguradoras migradas' AS tabla,
    COUNT(*) AS total
FROM aseguradora

UNION ALL

SELECT
    'Grúas migradas' AS tabla,
    COUNT(*) AS total
FROM grua

UNION ALL

SELECT
    'Relaciones incidente-vehiculo migradas' AS tabla,
    COUNT(*) AS total
FROM incidente_vehiculo

UNION ALL

SELECT
    'Relaciones incidente-grúa migradas' AS tabla,
    COUNT(*) AS total
FROM incidente_grua;

-- ========================================
-- IMPORTANTE: NO ELIMINAR TABLAS ANTIGUAS TODAVÍA
-- ========================================
-- Las tablas vehiculo_incidente y grua_involucrada se mantienen
-- por seguridad hasta verificar que todo funciona correctamente.
-- Se eliminarán en una migración posterior (025_cleanup.sql)
