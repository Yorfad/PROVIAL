const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkStatus() {
  try {
    console.log('📋 Verificando estado de migración 024...\n');

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

    console.log('Tablas creadas:');
    for (const table of tables) {
      try {
        const exists = await db.oneOrNone(
          `SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_name = $1
          )`,
          [table]
        );
        const count = exists?.exists ? await db.one(`SELECT COUNT(*) FROM ${table}`, [], r => +r.count) : 0;
        console.log(`  ${exists?.exists ? '✅' : '❌'} ${table}: ${count} registros`);
      } catch (err) {
        console.log(`  ❌ ${table}: Error - ${err.message}`);
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkStatus();
