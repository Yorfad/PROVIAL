const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provial_db';

async function run018() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    const sqlPath = path.join(__dirname, '018_mejorar_sistema_rutas_combustible.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Aplicando migración 018: Sistema de rutas y combustible...\n');
    await client.query(sql);

    console.log('✅ Migración 018 aplicada correctamente!\n');
    console.log('Cambios aplicados:');
    console.log('  - Campo ruta_activa_id agregado a asignacion_unidad');
    console.log('  - Campo combustible_fraccion agregado a situacion');
    console.log('  - Triggers para actualizar ruta activa automáticamente');
    console.log('  - Funciones para gestionar historial de combustible');
    console.log('  - Vista v_situaciones_con_combustible creada');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('\nDetalle:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

run018();
