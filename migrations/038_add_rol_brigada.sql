-- Migración 038: Agregar campo rol_brigada a usuario
-- Este campo define el rol específico del brigadista: PILOTO, COPILOTO, ACOMPAÑANTE

-- Agregar columna rol_brigada si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'rol_brigada'
    ) THEN
        ALTER TABLE usuario
        ADD COLUMN rol_brigada VARCHAR(20) CHECK (rol_brigada IN ('PILOTO', 'COPILOTO', 'ACOMPAÑANTE'));

        COMMENT ON COLUMN usuario.rol_brigada IS 'Rol específico del brigadista: PILOTO, COPILOTO, ACOMPAÑANTE';

        CREATE INDEX idx_usuario_rol_brigada ON usuario(rol_brigada) WHERE rol_brigada IS NOT NULL;
    END IF;
END
$$;

-- Eliminar todas las asignaciones de turno existentes para empezar limpio
DELETE FROM tripulacion_turno;
DELETE FROM turno_operativo;

-- Confirmar
SELECT 'Migración 038 completada: rol_brigada agregado y asignaciones eliminadas' as resultado;
