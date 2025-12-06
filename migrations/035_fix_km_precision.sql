
-- Aumentar precisión de columnas de kilometraje
ALTER TABLE asignacion_unidad 
    ALTER COLUMN km_inicio TYPE NUMERIC(10,2),
    ALTER COLUMN km_final TYPE NUMERIC(10,2),
    ALTER COLUMN km_recorridos TYPE NUMERIC(10,2);
