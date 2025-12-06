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
    console.log('📦 Aplicando migración 026: Mejoras al módulo de operaciones...\n');

    // Read migration file
    const migrationPath = path.join(__dirname, '..', 'migrations', '026_operaciones_enhancements.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    // Execute migration
    await db.none(sql);

    console.log('✅ Migración 026 aplicada exitosamente\n');

    // Verify changes
    console.log('📊 Verificando cambios:');

    // Check if telefono was added to usuario
    const userColumns = await db.any(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'usuario' AND column_name = 'telefono'
    `);
    console.log(userColumns.length > 0 ? '  ✓ Campo telefono agregado a usuario' : '  ✗ Error: telefono no agregado');

    // Check if combustible_actual was added to unidad
    const unidadColumns = await db.any(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'unidad' AND column_name = 'combustible_actual'
    `);
    console.log(unidadColumns.length > 0 ? '  ✓ Campo combustible_actual agregado a unidad' : '  ✗ Error: combustible_actual no agregado');

    // Check if combustible_registro table exists
    const combustibleTable = await db.oneOrNone(`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public' AND tablename = 'combustible_registro'
    `);
    console.log(combustibleTable ? '  ✓ Tabla combustible_registro creada' : '  ✗ Error: tabla no creada');

    // Check views
    console.log('\n📊 Vistas creadas:');
    const views = await db.any(`
      SELECT viewname FROM pg_views
      WHERE schemaname = 'public'
        AND viewname IN ('v_estadisticas_brigadas', 'v_estadisticas_unidades', 'v_disponibilidad_recursos')
      ORDER BY viewname
    `);
    views.forEach(view => {
      console.log(`  ✓ ${view.viewname}`);
    });

    // Check functions
    console.log('\n📊 Funciones creadas:');
    const functions = await db.any(`
      SELECT proname FROM pg_proc
      WHERE pronamespace = 'public'::regnamespace
        AND proname IN ('validar_disponibilidad_brigada', 'validar_disponibilidad_unidad', 'update_combustible_unidad')
      ORDER BY proname
    `);
    functions.forEach(func => {
      console.log(`  ✓ ${func.proname}()`);
    });

    console.log('\n✅ Migración completada exitosamente\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error aplicando migración:', error);
    process.exit(1);
  }
}

runMigration();
