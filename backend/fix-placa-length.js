const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function fixPlacaLength() {
  try {
    console.log('📝 Ampliando campo placa de VARCHAR(7) a VARCHAR(20)...\n');

    await db.none(`
      ALTER TABLE vehiculo
      ALTER COLUMN placa TYPE VARCHAR(20)
    `);

    console.log('✅ Campo placa actualizado exitosamente\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

fixPlacaLength();
