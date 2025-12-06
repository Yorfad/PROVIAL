const pgp = require('pg-promise')();

const db = pgp({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'provial_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkData() {
  try {
    console.log('📊 Verificando datos existentes...\n');

    // Check vehiculo_incidente count
    const vehiculoCount = await db.one('SELECT COUNT(*) FROM vehiculo_incidente', [], r => +r.count);
    console.log(`Total registros en vehiculo_incidente: ${vehiculoCount}`);

    if (vehiculoCount > 0) {
      // Sample record
      const sample = await db.one(`
        SELECT
          placa,
          tipo_vehiculo_id,
          marca_id,
          color,
          cargado,
          carga_tipo,
          tarjeta_circulacion,
          nit,
          licencia_tipo,
          licencia_numero,
          licencia_vencimiento,
          piloto_nacimiento,
          piloto_etnia,
          contenedor,
          contenedor_detalle,
          bus_extraurbano,
          bus_detalle
        FROM vehiculo_incidente
        LIMIT 1
      `);

      console.log('\nEjemplo de registro:');
      console.log(JSON.stringify(sample, null, 2));
    }

    // Check grua_involucrada count
    const gruaCount = await db.one('SELECT COUNT(*) FROM grua_involucrada', [], r => +r.count);
    console.log(`\nTotal registros en grua_involucrada: ${gruaCount}`);

    if (gruaCount > 0) {
      const gruaSample = await db.oneOrNone(`
        SELECT *
        FROM grua_involucrada
        WHERE empresa IS NOT NULL OR placa IS NOT NULL
        LIMIT 1
      `);

      if (gruaSample) {
        console.log('\nEjemplo de grúa:');
        console.log(JSON.stringify(gruaSample, null, 2));
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkData();
