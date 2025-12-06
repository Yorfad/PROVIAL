import { Request, Response } from 'express';
import { TurnoModel } from '../models/turno.model';

// GET /api/turnos/hoy - Obtener turno de hoy
export async function getTurnoHoy(_req: Request, res: Response) {
  try {
    const turno = await TurnoModel.findHoy();

    if (!turno) {
      return res.status(404).json({
        error: 'No hay turno programado para hoy',
        message: 'Contacta al departamento de Operaciones para crear el turno del día'
      });
    }

    // Obtener asignaciones
    const asignaciones = await TurnoModel.getAsignaciones(turno.id);

    return res.json({
      turno,
      asignaciones,
      total_asignaciones: asignaciones.length
    });
  } catch (error) {
    console.error('Error en getTurnoHoy:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// GET /api/turnos/mi-asignacion-hoy - Obtener mi asignación de hoy (para app móvil)
export async function getMiAsignacionHoy(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    console.log('getMiAsignacionHoy - UserID:', req.user.userId);
    const asignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);
    console.log('getMiAsignacionHoy - Resultado:', asignacion ? 'Encontrado' : 'NULL');

    if (!asignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy',
        message: 'No estás asignado a ninguna unidad el día de hoy. Contacta a Operaciones.'
      });
    }

    return res.json(asignacion);
  } catch (error) {
    console.error('Error en getMiAsignacionHoy:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos - Crear turno (solo Operaciones)
export async function createTurno(req: Request, res: Response) {
  try {
    const { fecha, observaciones } = req.body;

    if (!fecha) {
      return res.status(400).json({ error: 'La fecha es requerida' });
    }

    // Verificar que no exista ya un turno para esa fecha
    const existente = await TurnoModel.findByFecha(fecha);
    if (existente) {
      return res.status(409).json({
        error: 'Ya existe un turno para esa fecha',
        turno: existente
      });
    }

    const turno = await TurnoModel.create({
      fecha,
      observaciones,
      creado_por: req.user!.userId
    });

    return res.status(201).json({
      message: 'Turno creado exitosamente',
      turno
    });
  } catch (error) {
    console.error('Error en createTurno:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos/:id/asignaciones - Crear asignación de unidad
export async function createAsignacion(req: Request, res: Response) {
  try {
    const { id: turnoId } = req.params;
    const {
      unidad_id,
      ruta_id,
      km_inicio,
      km_final,
      sentido,
      acciones,
      combustible_inicial,
      combustible_asignado,
      hora_salida,
      hora_entrada_estimada,
      tripulacion // Array de { usuario_id, rol_tripulacion }
    } = req.body;

    if (!unidad_id) {
      return res.status(400).json({ error: 'unidad_id es requerido' });
    }

    // Crear asignación
    const asignacion = await TurnoModel.createAsignacion({
      turno_id: parseInt(turnoId),
      unidad_id,
      ruta_id,
      km_inicio,
      km_final,
      sentido,
      acciones,
      combustible_inicial,
      combustible_asignado,
      hora_salida,
      hora_entrada_estimada
    });

    // Agregar tripulación si se proporcionó
    const tripulacionCreada = [];
    if (tripulacion && Array.isArray(tripulacion)) {
      for (const miembro of tripulacion) {
        const t = await TurnoModel.addTripulacion({
          asignacion_id: asignacion.id,
          usuario_id: miembro.usuario_id,
          rol_tripulacion: miembro.rol_tripulacion
        });
        tripulacionCreada.push(t);
      }
    }

    return res.status(201).json({
      message: 'Asignación creada exitosamente',
      asignacion,
      tripulacion: tripulacionCreada
    });
  } catch (error: any) {
    console.error('Error en createAsignacion:', error);

    // Manejar errores de constraint
    if (error.code === '23505') { // Unique violation
      return res.status(409).json({
        error: 'La unidad ya tiene una asignación para este turno'
      });
    }

    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos/marcar-salida - Marcar salida de turno
export async function marcarSalida(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    // Obtener asignación del usuario para hoy
    const miAsignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);

    if (!miAsignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy'
      });
    }

    const asignacion = await TurnoModel.marcarSalida(miAsignacion.asignacion_id);

    return res.json({
      message: 'Salida registrada exitosamente',
      asignacion,
      hora_salida_real: asignacion.hora_salida_real
    });
  } catch (error) {
    console.error('Error en marcarSalida:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos/marcar-entrada - Marcar entrada de turno
export async function marcarEntrada(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { combustible_final, observaciones_finales } = req.body;

    const miAsignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);

    if (!miAsignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy'
      });
    }

    const asignacion = await TurnoModel.marcarEntrada(miAsignacion.asignacion_id, {
      combustible_final,
      observaciones_finales
    });

    return res.json({
      message: 'Entrada registrada exitosamente. Turno finalizado.',
      asignacion,
      resumen: {
        hora_salida: asignacion.hora_salida_real,
        hora_entrada: asignacion.hora_entrada_real,
        km_recorridos: asignacion.km_recorridos,
        combustible_usado: asignacion.combustible_inicial && combustible_final
          ? (asignacion.combustible_inicial - combustible_final).toFixed(2)
          : null
      }
    });
  } catch (error) {
    console.error('Error en marcarEntrada:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/reportes-horarios - Crear reporte horario (ultra-simplificado)
export async function createReporteHorario(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { km_actual, sentido_actual, latitud, longitud, novedad } = req.body;

    if (!km_actual) {
      return res.status(400).json({ error: 'km_actual es requerido' });
    }

    // Obtener asignación del usuario para hoy
    const miAsignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);

    if (!miAsignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy. No puedes crear reportes horarios.'
      });
    }

    const reporte = await TurnoModel.createReporteHorario({
      asignacion_id: miAsignacion.asignacion_id,
      km_actual,
      sentido_actual,
      latitud,
      longitud,
      novedad: novedad || 'Sin novedad',
      reportado_por: req.user.userId
    });

    return res.status(201).json({
      message: 'Reporte horario registrado exitosamente',
      reporte
    });
  } catch (error) {
    console.error('Error en createReporteHorario:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// GET /api/reportes-horarios/:asignacionId - Obtener reportes de una asignación
export async function getReportesHorarios(req: Request, res: Response) {
  try {
    const { asignacionId } = req.params;

    const reportes = await TurnoModel.getReportesHorarios(parseInt(asignacionId));

    return res.json({
      reportes,
      total: reportes.length
    });
  } catch (error) {
    console.error('Error en getReportesHorarios:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos/cambiar-ruta - Cambiar ruta activa de mi unidad
export async function cambiarRutaActiva(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { nueva_ruta_id } = req.body;

    if (!nueva_ruta_id) {
      return res.status(400).json({ error: 'nueva_ruta_id es requerido' });
    }

    // Obtener asignación del usuario para hoy
    const miAsignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);

    if (!miAsignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy'
      });
    }

    const asignacion = await TurnoModel.cambiarRutaActiva(
      miAsignacion.asignacion_id,
      parseInt(nueva_ruta_id)
    );

    return res.json({
      message: 'Ruta activa actualizada exitosamente',
      asignacion
    });
  } catch (error) {
    console.error('Error en cambiarRutaActiva:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// POST /api/turnos/registrar-combustible - Registrar combustible actual de mi unidad
export async function registrarCombustible(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { combustible, tipo, observaciones } = req.body;

    if (combustible === undefined || combustible === null) {
      return res.status(400).json({ error: 'El combustible es requerido' });
    }

    if (!tipo || !['INICIAL', 'ACTUAL', 'FINAL'].includes(tipo)) {
      return res.status(400).json({
        error: 'El tipo es requerido y debe ser INICIAL, ACTUAL o FINAL'
      });
    }

    // Obtener asignación del usuario para hoy
    const miAsignacion = await TurnoModel.getMiAsignacionHoy(req.user.userId);

    if (!miAsignacion) {
      return res.status(404).json({
        error: 'No tienes asignación para hoy'
      });
    }

    // Registrar el combustible
    const registro = await TurnoModel.registrarCombustible({
      asignacion_id: miAsignacion.asignacion_id,
      combustible: parseFloat(combustible),
      tipo,
      observaciones,
      registrado_por: req.user.userId
    });

    return res.status(201).json({
      message: 'Combustible registrado exitosamente',
      registro
    });
  } catch (error) {
    console.error('Error en registrarCombustible:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}
