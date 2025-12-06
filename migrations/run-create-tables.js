const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provial_db';

async function runCreateTables() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    const sqlPath = path.join(__dirname, 'create-missing-tables.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Creando tablas y funciones necesarias...\n');
    await client.query(sql);

    console.log('✅ Tablas y funciones creadas correctamente\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Detalle:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runCreateTables();
