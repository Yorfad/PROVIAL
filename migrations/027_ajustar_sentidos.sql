-- ========================================
-- Migración 027: Ajustar Sentidos a Solo 4 Direcciones
-- ========================================
-- Cambios:
-- 1. Actualizar tabla asignacion_unidad para solo permitir NORTE, SUR, ORIENTE, OCCIDENTE
-- ========================================

-- ========================================
-- 1. ACTUALIZAR CONSTRAINT DE SENTIDO EN ASIGNACION_UNIDAD
-- ========================================

-- Eliminar el constraint existente primero
ALTER TABLE asignacion_unidad DROP CONSTRAINT IF EXISTS asignacion_unidad_sentido_check;

-- Actualizar valores existentes de ESTE a ORIENTE y OESTE a OCCIDENTE
UPDATE asignacion_unidad SET sentido = 'ORIENTE' WHERE sentido = 'ESTE';
UPDATE asignacion_unidad SET sentido = 'OCCIDENTE' WHERE sentido = 'OESTE';

-- Actualizar valores de ASCENDENTE/DESCENDENTE/AMBOS a NULL o un valor por defecto
UPDATE asignacion_unidad SET sentido = NULL WHERE sentido IN ('ASCENDENTE', 'DESCENDENTE', 'AMBOS');

-- Agregar nuevo constraint con solo 4 sentidos
ALTER TABLE asignacion_unidad
ADD CONSTRAINT asignacion_unidad_sentido_check
CHECK (sentido IN ('NORTE', 'SUR', 'ORIENTE', 'OCCIDENTE'));

COMMENT ON COLUMN asignacion_unidad.sentido IS 'Sentido de recorrido: NORTE, SUR, ORIENTE, OCCIDENTE';
