const { Client } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL ||
  'postgresql://postgres:postgres@localhost:5432/provial_db';

async function check() {
  const client = new Client({ connectionString: DATABASE_URL });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL\n');

    // Verificar si la función verificar_acceso_app existe
    const result = await client.query(`
      SELECT EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'verificar_acceso_app'
      ) as existe
    `);

    console.log('Función verificar_acceso_app existe:', result.rows[0].existe);

    // Verificar si la tabla registro_cambio existe (creada en migración 017)
    const result2 = await client.query(`
      SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'registro_cambio'
      ) as existe
    `);

    console.log('Tabla registro_cambio existe:', result2.rows[0].existe);

    // Verificar si la columna exento_grupos existe
    const result3 = await client.query(`
      SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'usuario' AND column_name = 'exento_grupos'
      ) as existe
    `);

    console.log('Columna usuario.exento_grupos existe:', result3.rows[0].existe);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

check();
