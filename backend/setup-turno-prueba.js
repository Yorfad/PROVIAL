const { db } = require('./dist/config/database');

async function setupTurnoPrueba() {
  try {
    console.log('🔧 Configurando turno de prueba para hoy...\n');

    // 1. Verificar si ya existe un turno para hoy
    const turnoExistente = await db.oneOrNone(
      'SELECT * FROM turno WHERE fecha = CURRENT_DATE'
    );

    let turnoId;

    if (turnoExistente) {
      console.log('✓ Ya existe un turno para hoy:', turnoExistente.id);
      turnoId = turnoExistente.id;
    } else {
      // Crear turno para hoy
      const nuevoTurno = await db.one(
        `INSERT INTO turno (fecha, estado, observaciones, creado_por)
         VALUES (CURRENT_DATE, 'ACTIVO', 'Turno de prueba', 1)
         RETURNING *`
      );
      console.log('✓ Turno creado:', nuevoTurno.id);
      turnoId = nuevoTurno.id;
    }

    // 2. Obtener brigada01
    const brigada01 = await db.one(
      "SELECT * FROM usuario WHERE username = 'brigada01'"
    );
    console.log('✓ Usuario brigada01 encontrado:', brigada01.id);

    // 3. Obtener una unidad (la primera disponible)
    const unidad = await db.one(
      "SELECT * FROM unidad ORDER BY id LIMIT 1"
    );
    console.log('✓ Unidad asignada:', unidad.codigo);

    // 4. Obtener una ruta
    const ruta = await db.one(
      "SELECT * FROM ruta ORDER BY id LIMIT 1"
    );
    console.log('✓ Ruta asignada:', ruta.codigo);

    // 5. Verificar si ya existe asignación
    const asignacionExistente = await db.oneOrNone(
      `SELECT * FROM asignacion_unidad
       WHERE turno_id = $1 AND unidad_id = $2`,
      [turnoId, unidad.id]
    );

    let asignacionId;

    if (asignacionExistente) {
      console.log('✓ Ya existe asignación para esta unidad');
      asignacionId = asignacionExistente.id;
    } else {
      // Crear asignación de unidad
      const asignacion = await db.one(
        `INSERT INTO asignacion_unidad (
          turno_id, unidad_id, ruta_id,
          km_inicio, km_final, sentido,
          hora_salida, hora_entrada_estimada
        )
        VALUES ($1, $2, $3, 0, 100, 'AMBOS', '06:00', '18:00')
        RETURNING *`,
        [turnoId, unidad.id, ruta.id]
      );
      console.log('✓ Asignación de unidad creada:', asignacion.id);
      asignacionId = asignacion.id;
    }

    // 6. Verificar si brigada01 ya está en la tripulación
    const tripulacionExistente = await db.oneOrNone(
      `SELECT * FROM tripulacion_turno
       WHERE asignacion_id = $1 AND usuario_id = $2`,
      [asignacionId, brigada01.id]
    );

    if (tripulacionExistente) {
      console.log('✓ brigada01 ya está en la tripulación como', tripulacionExistente.rol_tripulacion);
    } else {
      // Asignar brigada01 como PILOTO
      await db.none(
        `INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente)
         VALUES ($1, $2, 'PILOTO', true)`,
        [asignacionId, brigada01.id]
      );
      console.log('✓ brigada01 asignado como PILOTO');
    }

    // 7. Verificar la asignación
    console.log('\n📋 Verificando asignación...');
    const miAsignacion = await db.oneOrNone(
      'SELECT * FROM v_mi_asignacion_hoy WHERE usuario_id = $1',
      [brigada01.id]
    );

    if (miAsignacion) {
      console.log('\n✅ ASIGNACIÓN COMPLETADA:');
      console.log('   Usuario:', miAsignacion.nombre_completo);
      console.log('   Unidad:', miAsignacion.unidad_codigo);
      console.log('   Ruta:', miAsignacion.ruta_codigo);
      console.log('   Rol:', miAsignacion.mi_rol);
      console.log('   Turno ID:', miAsignacion.turno_id);
      console.log('   Asignación ID:', miAsignacion.asignacion_id);
      console.log('\n🎉 brigada01 ya puede usar la app móvil!');
    } else {
      console.log('\n⚠️  No se pudo verificar la asignación');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

setupTurnoPrueba();
