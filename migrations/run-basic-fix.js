const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provial_db';

async function runBasicFix() {
  const client = new Client({
    connectionString: DATABASE_URL,
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    const sqlPath = path.join(__dirname, 'basic-fix.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Configurando usuario brigada01...\n');
    await client.query(sql);

    console.log('\n✅ Usuario configurado correctamente!\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runBasicFix();
