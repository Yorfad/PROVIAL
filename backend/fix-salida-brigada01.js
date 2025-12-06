const { db } = require('./dist/config/database');

async function fixSalidaBrigada01() {
  try {
    console.log('🔍 Buscando salida activa de brigada01...\n');

    // 1. Buscar salida activa
    const salida = await db.oneOrNone(`
      SELECT s.*, u.codigo as unidad_codigo
      FROM salida_unidad s
      JOIN brigada_unidad bu ON s.unidad_id = bu.unidad_id
      JOIN usuario usr ON bu.brigada_id = usr.id
      JOIN unidad u ON s.unidad_id = u.id
      WHERE usr.username = 'brigada01'
        AND s.estado = 'EN_SALIDA'
        AND bu.activo = TRUE
      ORDER BY s.id DESC
      LIMIT 1
    `);

    if (!salida) {
      console.log('❌ No hay salida activa para brigada01\n');
      process.exit(1);
    }

    console.log('✅ Salida activa encontrada:');
    console.log(`   ID: ${salida.id}`);
    console.log(`   Unidad: ${salida.unidad_codigo}`);
    console.log(`   Estado: ${salida.estado}`);
    console.log(`   Fecha/Hora Salida: ${salida.fecha_hora_salida}`);
    console.log(`   Ruta Inicial: ${salida.ruta_inicial_id || 'SIN RUTA'}`);
    console.log(`   Sede Origen: ${salida.sede_origen_id || 'SIN SEDE'}\n`);

    if (salida.ruta_inicial_id) {
      console.log('✅ La salida ya tiene ruta asignada\n');
      process.exit(0);
    }

    // 2. Buscar rutas disponibles
    const rutas = await db.any('SELECT id, codigo, nombre FROM ruta WHERE activa = true ORDER BY id LIMIT 5');

    console.log('📋 Rutas disponibles:');
    rutas.forEach(r => {
      console.log(`   ${r.id}. ${r.codigo} - ${r.nombre}`);
    });
    console.log('');

    if (rutas.length === 0) {
      console.log('❌ No hay rutas disponibles en la base de datos\n');
      process.exit(1);
    }

    // 3. Asignar la primera ruta disponible
    const rutaAsignar = rutas[0];

    console.log(`🔧 Asignando ruta ${rutaAsignar.codigo} a la salida...\n`);

    await db.none(
      'UPDATE salida_unidad SET ruta_inicial_id = $1 WHERE id = $2',
      [rutaAsignar.id, salida.id]
    );

    console.log('✅ ¡Ruta asignada exitosamente!');
    console.log(`   Salida ID: ${salida.id}`);
    console.log(`   Ruta: ${rutaAsignar.codigo} - ${rutaAsignar.nombre}\n`);

    // 4. Verificar actualización
    const verificar = await db.one(
      'SELECT s.*, r.codigo as ruta_codigo, r.nombre as ruta_nombre FROM salida_unidad s LEFT JOIN ruta r ON s.ruta_inicial_id = r.id WHERE s.id = $1',
      [salida.id]
    );

    console.log('✅ Verificación:');
    console.log(`   Ruta asignada: ${verificar.ruta_codigo} - ${verificar.ruta_nombre}\n`);

    console.log('🎉 brigada01 ahora puede cambiar de ruta y registrar situaciones en rutas.\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

fixSalidaBrigada01();
