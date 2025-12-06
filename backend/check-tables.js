const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkTables() {
  try {
    console.log('📋 Tablas que contienen información de incidentes/situaciones:\n');

    // Check if incidente table exists
    const incidente = await db.oneOrNone(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'incidente'
      )
    `);

    if (incidente?.exists) {
      const count = await db.one('SELECT COUNT(*) FROM incidente', [], r => +r.count);
      console.log(`✓ incidente (${count} registros)`);

      const sample = await db.oneOrNone('SELECT * FROM incidente LIMIT 1');
      if (sample) {
        console.log('  Columnas:', Object.keys(sample).join(', '));
      }
    } else {
      console.log('❌ Tabla "incidente" no existe');
    }

    // Check if situacion table exists
    const situacion = await db.oneOrNone(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'situacion'
      )
    `);

    if (situacion?.exists) {
      const count = await db.one('SELECT COUNT(*) FROM situacion', [], r => +r.count);
      console.log(`\n✓ situacion (${count} registros)`);

      const sample = await db.oneOrNone('SELECT * FROM situacion LIMIT 1');
      if (sample) {
        console.log('  Columnas:', Object.keys(sample).slice(0, 15).join(', '), '...');
      }
    } else {
      console.log('\n❌ Tabla "situacion" no existe');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkTables();
