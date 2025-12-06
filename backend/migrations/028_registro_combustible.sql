-- ============================================
-- Migración 028: Tabla de Registro de Combustible
-- Descripción: Permite a las brigadas registrar el combustible
--              en cualquier momento durante su jornada
-- ============================================

-- Crear tabla de registro de combustible
CREATE TABLE IF NOT EXISTS registro_combustible (
  id SERIAL PRIMARY KEY,
  asignacion_id INTEGER NOT NULL REFERENCES asignacion_unidad(id) ON DELETE CASCADE,
  combustible DECIMAL(10, 2) NOT NULL CHECK (combustible >= 0),
  tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('INICIAL', 'ACTUAL', 'FINAL')),
  observaciones TEXT,
  registrado_por INTEGER NOT NULL REFERENCES usuario(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT registro_combustible_valido CHECK (combustible <= 1000)
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_registro_combustible_asignacion ON registro_combustible(asignacion_id);
CREATE INDEX idx_registro_combustible_fecha ON registro_combustible(created_at);
CREATE INDEX idx_registro_combustible_tipo ON registro_combustible(tipo);

-- Comentarios
COMMENT ON TABLE registro_combustible IS 'Registros de combustible realizados por las brigadas durante su jornada';
COMMENT ON COLUMN registro_combustible.tipo IS 'INICIAL: al inicio del turno, ACTUAL: durante el turno, FINAL: al finalizar';
COMMENT ON COLUMN registro_combustible.combustible IS 'Cantidad de combustible en litros';

-- ============================================
-- Vista para facilitar consultas de registros
-- ============================================

CREATE OR REPLACE VIEW v_registros_combustible AS
SELECT
  rc.id,
  rc.asignacion_id,
  rc.combustible,
  rc.tipo,
  rc.observaciones,
  rc.created_at,
  -- Información del turno
  t.id as turno_id,
  t.fecha as fecha_turno,
  -- Información de la unidad
  u.id as unidad_id,
  u.codigo as unidad_codigo,
  u.tipo_unidad,
  -- Información del usuario que registró
  usr.id as registrado_por_id,
  usr.nombre_completo as registrado_por_nombre,
  -- Información de la asignación
  au.hora_salida_real,
  au.hora_entrada_real
FROM registro_combustible rc
JOIN asignacion_unidad au ON rc.asignacion_id = au.id
JOIN turno t ON au.turno_id = t.id
JOIN unidad u ON au.unidad_id = u.id
JOIN usuario usr ON rc.registrado_por = usr.id;

COMMENT ON VIEW v_registros_combustible IS 'Vista completa de registros de combustible con información relacionada';
