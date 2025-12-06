const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provial_db';

async function runMigrations() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL');
    console.log('=====================================');
    console.log('Ejecutando migraciones de PostgreSQL');
    console.log('=====================================\n');

    // Leer todos los archivos .sql en orden
    const migrationsDir = __dirname;
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');

      console.log(`▶ Ejecutando: ${file}`);
      try {
        await client.query(sql);
        console.log(`✓ Completado: ${file}\n`);
      } catch (error) {
        console.error(`❌ Error en ${file}:`, error.message);
        // Continuar con la siguiente migración incluso si hay error
      }
    }

    console.log('=====================================');
    console.log('✅ Migraciones completadas');
    console.log('=====================================\n');

    // Refrescar vistas materializadas si existen
    try {
      console.log('Refrescando vistas materializadas...');
      await client.query('REFRESH MATERIALIZED VIEW CONCURRENTLY mv_estadisticas_diarias');
      await client.query('REFRESH MATERIALIZED VIEW CONCURRENTLY mv_no_atendidos_por_motivo');
      console.log('✓ Vistas materializadas actualizadas\n');
    } catch (error) {
      console.log('⚠ Vistas materializadas no encontradas (es normal en primera ejecución)\n');
    }

    console.log('Listo para usar! 🚀');
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigrations();
