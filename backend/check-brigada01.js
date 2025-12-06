const { db } = require('./dist/config/database');

async function checkBrigada01() {
  try {
    console.log('🔍 Verificando estado de brigada01...\n');

    // 1. Verificar usuario
    const user = await db.oneOrNone("SELECT * FROM usuario WHERE username = 'brigada01'");

    if (!user) {
      console.log('❌ ERROR: Usuario brigada01 no existe');
      process.exit(1);
    }

    console.log('✅ Usuario encontrado:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Nombre: ${user.nombre} ${user.apellido}`);
    console.log(`   Rol: ${user.rol}`);
    console.log(`   Grupo: ${user.grupo}`);
    console.log(`   Acceso App: ${user.acceso_app_activo ? 'ACTIVO' : 'BLOQUEADO'}`);
    console.log(`   Exento Grupos: ${user.exento_grupos}`);
    console.log(`   Fecha Inicio Ciclo: ${user.fecha_inicio_ciclo}\n`);

    // 2. Verificar asignación permanente
    const asignacion = await db.oneOrNone(`
      SELECT a.id, a.brigada_id, a.unidad_id, a.rol_tripulacion, a.activo,
             u.codigo as unidad_codigo, u.tipo_unidad, u.sede_id,
             s.codigo as sede_codigo, s.nombre as sede_nombre
      FROM brigada_unidad a
      INNER JOIN unidad u ON a.unidad_id = u.id
      LEFT JOIN sede s ON u.sede_id = s.id
      WHERE a.brigada_id = $1 AND a.activo = TRUE
      ORDER BY a.id DESC
      LIMIT 1
    `, [user.id]);

    if (!asignacion) {
      console.log('❌ ERROR: brigada01 NO tiene asignación permanente de unidad\n');
      console.log('📝 SOLUCIÓN: Ejecuta este SQL:');
      console.log('');
      console.log('INSERT INTO brigada_unidad (brigada_id, unidad_id, rol_tripulacion, activo, fecha_asignacion)');
      console.log(`VALUES (${user.id}, 1, 'PILOTO', TRUE, CURRENT_DATE);`);
      console.log('');
      process.exit(1);
    }

    console.log('✅ Asignación Permanente encontrada:');
    console.log(`   ID: ${asignacion.id}`);
    console.log(`   Unidad: ${asignacion.unidad_codigo} (${asignacion.tipo_unidad})`);
    console.log(`   Rol: ${asignacion.rol_tripulacion}`);
    console.log(`   Activo: ${asignacion.activo ? 'SÍ' : 'NO'}`);
    console.log(`   Sede: ${asignacion.sede_codigo || 'SIN SEDE'} ${asignacion.sede_nombre || ''}\n`);

    // 3. Verificar estado del grupo
    const hoy = new Date().toISOString().split('T')[0];
    const calendarioHoy = await db.oneOrNone(`
      SELECT c.fecha, c.grupo, c.estado, c.observaciones
      FROM calendario_grupo c
      WHERE c.grupo = $1 AND c.fecha = $2
    `, [user.grupo, hoy]);

    if (!calendarioHoy) {
      console.log(`⚠️  ADVERTENCIA: No hay entrada de calendario para el grupo ${user.grupo} en la fecha ${hoy}`);
      console.log('   El sistema verificará acceso basándose en el patrón del calendario.\n');
    } else {
      console.log('📅 Calendario de hoy:');
      console.log(`   Grupo: ${calendarioHoy.grupo}`);
      console.log(`   Estado: ${calendarioHoy.estado}`);
      console.log(`   Observaciones: ${calendarioHoy.observaciones || 'N/A'}\n`);
    }

    // 4. Verificar acceso usando la función del sistema
    const accesoResult = await db.one('SELECT * FROM verificar_acceso_app($1)', [user.id]);

    console.log('🔐 Verificación de Acceso a la App:');
    console.log(`   Tiene Acceso: ${accesoResult.tiene_acceso ? '✅ SÍ' : '❌ NO'}`);
    if (!accesoResult.tiene_acceso) {
      console.log(`   Motivo Bloqueo: ${accesoResult.motivo_bloqueo}`);
      console.log(`   Detalle: ${accesoResult.detalle}\n`);
    } else {
      console.log(`   Detalle: ${accesoResult.detalle}\n`);
    }

    // 5. Resumen final
    console.log('='.repeat(60));
    console.log('📊 RESUMEN FINAL:\n');

    const issues = [];

    // Nota: Las rutas ya no se asignan a nivel de brigada_unidad, sino a nivel de salida_unidad
    console.log('ℹ️  Las rutas se asignan por salida, no por asignación permanente\n');

    if (!asignacion.sede_id) {
      issues.push('❌ Unidad sin sede asignada');
      console.log('❌ Unidad sin sede asignada - NECESITA CORRECCIÓN');
      console.log(`   SQL: UPDATE unidad SET sede_id = 1 WHERE id = ${asignacion.unidad_id};\n`);
    } else {
      console.log(`✅ Sede asignada: ${asignacion.sede_codigo}\n`);
    }

    if (!user.acceso_app_activo) {
      issues.push('❌ Acceso a la app bloqueado');
      console.log('❌ Acceso a la app bloqueado - NECESITA CORRECCIÓN');
      console.log(`   SQL: UPDATE usuario SET acceso_app_activo = true WHERE id = ${user.id};\n`);
    } else {
      console.log('✅ Acceso a la app: ACTIVO\n');
    }

    if (!accesoResult.tiene_acceso) {
      issues.push(`❌ Bloqueo por calendario: ${accesoResult.motivo_bloqueo}`);
      console.log(`❌ ${accesoResult.motivo_bloqueo}`);
      console.log(`   ${accesoResult.detalle}\n`);
    } else {
      console.log('✅ Calendario: Tiene acceso hoy\n');
    }

    console.log('='.repeat(60));

    if (issues.length === 0) {
      console.log('\n🎉 ¡TODO ESTÁ CORRECTO! brigada01 puede usar la app móvil.\n');
    } else {
      console.log('\n⚠️  PROBLEMAS ENCONTRADOS:\n');
      issues.forEach(issue => console.log(`   ${issue}`));
      console.log('\n📝 Ejecuta los SQL sugeridos arriba para corregir.\n');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

checkBrigada01();
