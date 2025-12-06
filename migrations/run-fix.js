const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provial_db';

async function runFix() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    const sqlPath = path.join(__dirname, 'fix-for-app.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Ejecutando fix-for-app.sql...\n');
    const result = await client.query(sql);

    console.log('\n✅ Script ejecutado correctamente\n');

    // Si hay resultados, mostrarlos
    if (result.rows && result.rows.length > 0) {
      console.log('Resultados:');
      console.log(JSON.stringify(result.rows, null, 2));
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runFix();
