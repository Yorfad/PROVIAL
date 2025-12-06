const { Client } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL ||
  'postgresql://postgres:postgres@localhost:5432/provial_db';

async function fix017() {
  const client = new Client({ connectionString: DATABASE_URL });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    // Crear tabla registro_cambio
    console.log('Creando tabla registro_cambio...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS registro_cambio (
          id BIGSERIAL PRIMARY KEY,

          -- Tipo de cambio
          tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN (
              'CAMBIO_BRIGADA',           -- Cambio de brigada en asignación
              'CAMBIO_UNIDAD',            -- Cambio de unidad
              'REMOCION_ASIGNACION',      -- Remover brigada de asignación
              'SUSPENSION_ACCESO',        -- Suspender acceso a app
              'REACTIVACION_ACCESO',      -- Reactivar acceso
              'CAMBIO_GRUPO',             -- Cambiar de grupo 1 a 2 o viceversa
              'EDICION_SITUACION',        -- Editar situación de día cerrado
              'EDICION_ASIGNACION',       -- Editar asignación de día cerrado
              'OTRO'
          )),

          -- Entidades afectadas
          usuario_afectado_id INT REFERENCES usuario(id) ON DELETE SET NULL,
          asignacion_id INT REFERENCES asignacion_unidad(id) ON DELETE SET NULL,
          situacion_id BIGINT REFERENCES situacion(id) ON DELETE SET NULL,
          unidad_id INT REFERENCES unidad(id) ON DELETE SET NULL,

          -- Valores anteriores y nuevos (JSON para flexibilidad)
          valores_anteriores JSONB,
          valores_nuevos JSONB,

          -- Motivo del cambio (OBLIGATORIO)
          motivo TEXT NOT NULL,

          -- Quien autorizó/realizó el cambio
          realizado_por INT NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
          autorizado_por INT REFERENCES usuario(id) ON DELETE SET NULL,

          -- Auditoría
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla registro_cambio creada\n');

    // Crear índices
    console.log('Creando índices...');
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_registro_tipo ON registro_cambio(tipo_cambio);
      CREATE INDEX IF NOT EXISTS idx_registro_usuario ON registro_cambio(usuario_afectado_id);
      CREATE INDEX IF NOT EXISTS idx_registro_asignacion ON registro_cambio(asignacion_id);
      CREATE INDEX IF NOT EXISTS idx_registro_fecha ON registro_cambio(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_registro_realizado_por ON registro_cambio(realizado_por);
    `);
    console.log('✅ Índices creados\n');

    console.log('✅ Fix 017 completado!');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

fix017();
