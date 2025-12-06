const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkIndexes() {
  try {
    console.log('🔍 Verificando índices existentes...\n');

    const indexes = await db.any(`
      SELECT indexname, tablename
      FROM pg_indexes
      WHERE schemaname = 'public'
        AND (indexname LIKE 'idx_vehiculo%'
          OR indexname LIKE 'idx_piloto%'
          OR indexname LIKE 'idx_grua%'
          OR indexname LIKE 'idx_aseguradora%'
          OR indexname LIKE 'idx_tc%'
          OR indexname LIKE 'idx_contenedor%'
          OR indexname LIKE 'idx_bus%'
          OR indexname LIKE 'idx_sancion%'
          OR indexname LIKE 'idx_incidente_vehiculo%'
          OR indexname LIKE 'idx_incidente_grua%')
      ORDER BY tablename, indexname
    `);

    if (indexes.length === 0) {
      console.log('No hay índices de migración 024');
    } else {
      console.log(`Encontrados ${indexes.length} índices:`);
      indexes.forEach(idx => {
        console.log(`  - ${idx.indexname} (tabla: ${idx.tablename || 'N/A'})`);
      });
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkIndexes();
