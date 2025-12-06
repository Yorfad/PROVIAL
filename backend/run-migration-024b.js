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
    console.log('📦 Aplicando migración 024b: Migración de datos existentes...\n');

    // Read migration file
    const migrationPath = path.join(__dirname, '..', 'migrations', '024b_migrate_existing_data.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Execute migration
    const result = await db.multi(sql);

    console.log('✅ Migración 024b aplicada exitosamente\n');

    // Show the summary from the last query result
    if (result && result.length > 0) {
      const summary = result[result.length - 1];
      console.log('📊 Resumen de migración:');
      console.log('==========================================');
      summary.forEach(row => {
        console.log(`  ${row.tabla.padEnd(45)}: ${row.total} registros`);
      });
      console.log('==========================================\n');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error aplicando migración:', error);
    if (error.position) {
      console.error(`Posición del error: ${error.position}`);
    }
    if (error.query) {
      console.error(`Query: ${error.query.substring(0, 500)}...`);
    }
    process.exit(1);
  }
}

runMigration();
