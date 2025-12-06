
import { db } from '../config/database';

async function generateAssignment() {
    try {
        console.log('Iniciando generación de asignación...');

        // 1. Obtener usuario brigada01
        const usuario = await db.oneOrNone("SELECT id FROM usuario WHERE username = 'brigada01'");
        if (!usuario) {
            console.error('Usuario brigada01 no encontrado');
            return;
        }
        console.log('Usuario encontrado:', usuario.id);

        // 2. Obtener unidad 1104
        const unidad = await db.oneOrNone("SELECT id FROM unidad WHERE codigo = '1104'");
        if (!unidad) {
            console.error('Unidad 1104 no encontrada');
            return;
        }
        console.log('Unidad encontrada:', unidad.id);

        // 3. Obtener ruta CA-1 Occidente
        const ruta = await db.oneOrNone("SELECT id FROM ruta WHERE codigo = 'CA-1 Occidente'");
        if (!ruta) {
            console.error('Ruta CA-1 Occidente no encontrada');
            return;
        }
        console.log('Ruta encontrada:', ruta.id);

        // 4. Crear o obtener turno de hoy
        let turno = await db.oneOrNone("SELECT id FROM turno WHERE fecha = CURRENT_DATE");
        if (!turno) {
            console.log('Creando turno para hoy...');
            turno = await db.one(
                "INSERT INTO turno (fecha, estado, creado_por) VALUES (CURRENT_DATE, 'ACTIVO', $1) RETURNING id",
                [usuario.id] // Creado por el mismo usuario para simplificar, o podría ser admin (1)
            );
        }
        console.log('Turno ID:', turno.id);

        // 5. Crear asignación
        console.log('Creando asignación de unidad...');
        const asignacion = await db.one(
            `INSERT INTO asignacion_unidad 
       (turno_id, unidad_id, ruta_id, km_inicio, combustible_inicial, combustible_asignado, hora_salida)
       VALUES ($1, $2, $3, 150000, 60, 60, '06:00:00')
       RETURNING id`,
            [turno.id, unidad.id, ruta.id]
        );
        console.log('Asignación creada:', asignacion.id);

        // 6. Asignar tripulación
        console.log('Asignando tripulación...');
        await db.none(
            "INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES ($1, $2, 'PILOTO', true)",
            [asignacion.id, usuario.id]
        );

        console.log('✅ Asignación completada exitosamente para brigada01');
        process.exit(0);
    } catch (error) {
        console.error('Error generando asignación:', error);
        process.exit(1);
    }
}

generateAssignment();
