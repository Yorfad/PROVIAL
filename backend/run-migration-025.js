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
    console.log('📦 Aplicando migración 025: Vistas de inteligencia...\n');

    // Read migration file
    const migrationPath = path.join(__dirname, '..', 'migrations', '025_intelligence_views.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Execute migration
    await db.none(sql);

    console.log('✅ Migración 025 aplicada exitosamente\n');

    // Verify views were created
    console.log('📊 Verificando vistas creadas:');

    const views = await db.any(`
      SELECT matviewname, schemaname
      FROM pg_matviews
      WHERE schemaname = 'public'
        AND matviewname LIKE 'mv_%'
      ORDER BY matviewname
    `);

    views.forEach(view => {
      console.log(`  ✓ ${view.matviewname}`);
    });

    console.log('\n📝 Refrescando vistas inicialmente...');
    try {
      await db.none('SELECT refresh_intelligence_views()');
      console.log('✅ Vistas refrescadas exitosamente\n');
    } catch (err) {
      // Ignore the "no return data expected" error for VOID functions
      if (err.code !== 0 || !err.message.includes('No return data was expected')) {
        throw err;
      }
      console.log('✅ Vistas refrescadas exitosamente\n');
    }

    // Show counts
    console.log('📊 Registros en cada vista:');
    const vehiculos = await db.one('SELECT COUNT(*) FROM mv_vehiculos_reincidentes', [], r => +r.count);
    const pilotos = await db.one('SELECT COUNT(*) FROM mv_pilotos_problematicos', [], r => +r.count);
    const puntos = await db.one('SELECT COUNT(*) FROM mv_puntos_calientes', [], r => +r.count);
    const tendencias = await db.one('SELECT COUNT(*) FROM mv_tendencias_temporales', [], r => +r.count);

    console.log(`  - Vehículos reincidentes: ${vehiculos}`);
    console.log(`  - Pilotos problemáticos: ${pilotos}`);
    console.log(`  - Puntos calientes: ${puntos}`);
    console.log(`  - Tendencias temporales: ${tendencias}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error aplicando migración:', error);
    process.exit(1);
  }
}

runMigration();
