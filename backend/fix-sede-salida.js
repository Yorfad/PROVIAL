const { db } = require('./dist/config/database');

(async () => {
  try {
    const sede = await db.one("SELECT id FROM sede WHERE codigo = 'CENTRAL'");
    await db.none('UPDATE salida_unidad SET sede_origen_id = $1 WHERE id = 2', [sede.id]);

    console.log('✅ Sede de origen (CENTRAL) asignada a la salida\n');

    const verificar = await db.one(`
      SELECT s.*, r.codigo as ruta_codigo, sed.codigo as sede_codigo
      FROM salida_unidad s
      LEFT JOIN ruta r ON s.ruta_inicial_id = r.id
      LEFT JOIN sede sed ON s.sede_origen_id = sed.id
      WHERE s.id = 2
    `);

    console.log('📊 Estado final de la salida:');
    console.log(`   Salida ID: ${verificar.id}`);
    console.log(`   Ruta Inicial: ${verificar.ruta_codigo}`);
    console.log(`   Sede Origen: ${verificar.sede_codigo}`);
    console.log(`   Estado: ${verificar.estado}\n`);

    console.log('🎉 ¡Todo configurado! brigada01 puede usar la app completamente.\n');
  } catch(e) {
    console.error('Error:', e.message);
  } finally {
    process.exit();
  }
})();
