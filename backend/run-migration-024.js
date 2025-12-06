const fs = require('fs');
const path = require('path');
const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function runMigration() {
  try {
    console.log('📦 Aplicando migración 024: Normalización de datos...\n');

    // Read migration file
    const migrationPath = path.join(__dirname, '..', 'migrations', '024_normalize_incident_data.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Execute migration
    await db.none(sql);

    console.log('✅ Migración 024 aplicada exitosamente\n');

    // Show summary
    console.log('📊 Resumen de tablas creadas:');
    const tables = [
      'vehiculo',
      'tarjeta_circulacion',
      'piloto',
      'contenedor',
      'bus',
      'articulo_sancion',
      'sancion',
      'grua',
      'aseguradora',
      'incidente_vehiculo',
      'incidente_grua'
    ];

    for (const table of tables) {
      const count = await db.one(`SELECT COUNT(*) FROM ${table}`, [], r => +r.count);
      console.log(`  - ${table}: ${count} registros`);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error aplicando migración:', error);
    process.exit(1);
  }
}

runMigration();
