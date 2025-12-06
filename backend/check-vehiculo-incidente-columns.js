const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkColumns() {
  try {
    console.log('📋 Columnas de vehiculo_incidente:\n');

    const columns = await db.any(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'vehiculo_incidente'
      ORDER BY ordinal_position
    `);

    columns.forEach(col => {
      console.log(`  - ${col.column_name.padEnd(30)} ${col.data_type.padEnd(20)} ${col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });

    console.log('\n📋 Columnas de grua_involucrada:\n');

    const gruaColumns = await db.any(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'grua_involucrada'
      ORDER BY ordinal_position
    `);

    gruaColumns.forEach(col => {
      console.log(`  - ${col.column_name.padEnd(30)} ${col.data_type.padEnd(20)} ${col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkColumns();
