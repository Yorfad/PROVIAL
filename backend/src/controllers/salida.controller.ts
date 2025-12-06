import { Request, Response } from 'express';
import { SalidaModel } from '../models/salida.model';
import { GrupoModel } from '../models/grupo.model';

// ========================================
// ASIGNACIONES PERMANENTES
// ========================================

/**
 * GET /api/salidas/mi-unidad
 * Obtener mi unidad asignada permanentemente
 */
export async function getMiUnidad(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const miUnidad = await SalidaModel.getMiUnidadAsignada(req.user.userId);

    if (!miUnidad) {
      return res.status(404).json({
        error: 'No tienes unidad asignada',
        message: 'No estás asignado permanentemente a ninguna unidad. Contacta a tu supervisor.'
      });
    }

    return res.json(miUnidad);
  } catch (error) {
    console.error('Error en getMiUnidad:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/salidas/asignar-brigada
 * Asignar brigadista a unidad permanentemente (solo Operaciones/Admin)
 */
export async function asignarBrigadaAUnidad(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { brigada_id, unidad_id, rol_tripulacion, observaciones } = req.body;

    if (!brigada_id || !unidad_id || !rol_tripulacion) {
      return res.status(400).json({
        error: 'Faltan campos requeridos',
        required: ['brigada_id', 'unidad_id', 'rol_tripulacion']
      });
    }

    // Verificar roles válidos
    const rolesValidos = ['PILOTO', 'COPILOTO', 'ACOMPAÑANTE'];
    if (!rolesValidos.includes(rol_tripulacion)) {
      return res.status(400).json({
        error: 'Rol inválido',
        roles_validos: rolesValidos
      });
    }

    // Verificar que el brigada no esté de descanso (sin asignación previa)
    // Si el grupo está en DESCANSO y no tiene asignación, verificarAccesoApp retornará false
    const acceso = await GrupoModel.verificarAccesoApp(brigada_id);
    if (!acceso.tiene_acceso) {
      return res.status(400).json({
        error: 'No se puede asignar a unidad',
        motivo: acceso.motivo_bloqueo
      });
    }

    const asignacion = await SalidaModel.asignarBrigadaAUnidad({
      brigada_id,
      unidad_id,
      rol_tripulacion,
      asignado_por: req.user.userId,
      observaciones
    });

    return res.status(201).json({
      message: 'Brigadista asignado exitosamente',
      asignacion
    });
  } catch (error: any) {
    console.error('Error en asignarBrigadaAUnidad:', error);

    if (error.code === '23505') { // Unique violation
      return res.status(409).json({
        error: 'El brigadista ya tiene una asignación activa'
      });
    }

    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/salidas/tripulacion/:unidadId
 * Obtener tripulación de una unidad
 */
export async function getTripulacion(req: Request, res: Response) {
  try {
    const { unidadId } = req.params;

    const tripulacion = await SalidaModel.getTripulacionUnidad(parseInt(unidadId));

    return res.json({
      unidad_id: parseInt(unidadId),
      tripulacion,
      total: tripulacion.length
    });
  } catch (error) {
    console.error('Error en getTripulacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// SALIDAS
// ========================================

/**
 * GET /api/salidas/mi-salida-activa
 * Obtener mi salida activa (si existe)
 */
export async function getMiSalidaActiva(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const miSalida = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (!miSalida) {
      return res.status(404).json({
        error: 'No tienes salida activa',
        message: 'Tu unidad no ha iniciado salida. Registra SALIDA_SEDE para comenzar.'
      });
    }

    return res.json(miSalida);
  } catch (error) {
    console.error('Error en getMiSalidaActiva:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/salidas/iniciar
 * Iniciar salida de mi unidad
 */
export async function iniciarSalida(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    // Obtener mi unidad
    const miUnidad = await SalidaModel.getMiUnidadAsignada(req.user.userId);

    if (!miUnidad) {
      return res.status(404).json({
        error: 'No tienes unidad asignada'
      });
    }

    // Verificar que no haya salida activa
    const salidaActiva = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (salidaActiva) {
      return res.status(409).json({
        error: 'Ya tienes una salida activa',
        salida: salidaActiva
      });
    }

    const {
      ruta_inicial_id,
      km_inicial,
      combustible_inicial,
      observaciones_salida
    } = req.body;

    // Iniciar salida
    const salidaId = await SalidaModel.iniciarSalida({
      unidad_id: miUnidad.unidad_id,
      ruta_inicial_id,
      km_inicial,
      combustible_inicial,
      observaciones_salida
    });

    // Obtener info de la salida creada
    const salida = await SalidaModel.getSalidaById(salidaId);

    return res.status(201).json({
      message: 'Salida iniciada exitosamente',
      salida_id: salidaId,
      salida,
      instruccion: 'Ahora debes registrar SALIDA_SEDE como primera situación'
    });
  } catch (error: any) {
    console.error('Error en iniciarSalida:', error);

    if (error.message && error.message.includes('ya tiene una salida activa')) {
      return res.status(409).json({
        error: 'La unidad ya tiene una salida activa'
      });
    }

    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/salidas/:id/finalizar
 * Finalizar salida
 */
export async function finalizarSalida(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { id } = req.params;
    const { km_final, combustible_final, observaciones_regreso } = req.body;

    const success = await SalidaModel.finalizarSalida({
      salida_id: parseInt(id),
      km_final,
      combustible_final,
      observaciones_regreso,
      finalizada_por: req.user.userId
    });

    if (!success) {
      return res.status(404).json({
        error: 'Salida no encontrada o ya finalizada'
      });
    }

    const salida = await SalidaModel.getSalidaById(parseInt(id));

    return res.json({
      message: 'Salida finalizada exitosamente',
      salida
    });
  } catch (error) {
    console.error('Error en finalizarSalida:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/salidas/cambiar-ruta
 * Cambiar ruta de mi salida activa
 */
export async function cambiarRuta(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { nueva_ruta_id } = req.body;

    if (!nueva_ruta_id) {
      return res.status(400).json({
        error: 'El campo nueva_ruta_id es requerido'
      });
    }

    // Obtener mi salida activa
    const miSalida = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (!miSalida) {
      return res.status(404).json({
        error: 'No tienes salida activa'
      });
    }

    // Cambiar ruta
    const success = await SalidaModel.cambiarRuta(miSalida.salida_id, nueva_ruta_id);

    if (!success) {
      return res.status(404).json({
        error: 'No se pudo cambiar la ruta. La salida podría no estar activa.'
      });
    }

    // Obtener salida actualizada
    const salidaActualizada = await SalidaModel.getMiSalidaActiva(req.user.userId);

    return res.json({
      message: 'Ruta cambiada exitosamente',
      salida: salidaActualizada
    });
  } catch (error) {
    console.error('Error en cambiarRuta:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/salidas/:id
 * Obtener información de una salida
 */
export async function getSalida(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const salida = await SalidaModel.getSalidaById(parseInt(id));

    if (!salida) {
      return res.status(404).json({ error: 'Salida no encontrada' });
    }

    // Obtener situaciones de la salida
    const situaciones = await SalidaModel.getSituacionesDeSalida(salida.id);

    return res.json({
      salida,
      situaciones,
      total_situaciones: situaciones.length
    });
  } catch (error) {
    console.error('Error en getSalida:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/salidas/unidades-en-salida
 * Obtener todas las unidades actualmente en salida (para COP/Operaciones)
 */
export async function getUnidadesEnSalida(_req: Request, res: Response) {
  try {
    const unidades = await SalidaModel.getUnidadesEnSalida();

    return res.json({
      unidades,
      total: unidades.length
    });
  } catch (error) {
    console.error('Error en getUnidadesEnSalida:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/salidas/historial/:unidadId
 * Obtener historial de salidas de una unidad
 */
export async function getHistorialSalidas(req: Request, res: Response) {
  try {
    const { unidadId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;

    const historial = await SalidaModel.getHistorialSalidas(parseInt(unidadId), limit);

    return res.json({
      unidad_id: parseInt(unidadId),
      historial,
      total: historial.length
    });
  } catch (error) {
    console.error('Error en getHistorialSalidas:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// RELEVOS
// ========================================

/**
 * POST /api/salidas/relevos
 * Registrar relevo de unidades/tripulaciones
 */
export async function registrarRelevo(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const {
      situacion_id,
      tipo_relevo,
      unidad_saliente_id,
      unidad_entrante_id,
      brigadistas_salientes,
      brigadistas_entrantes,
      observaciones
    } = req.body;

    if (!tipo_relevo || !unidad_saliente_id || !unidad_entrante_id) {
      return res.status(400).json({
        error: 'Faltan campos requeridos',
        required: ['tipo_relevo', 'unidad_saliente_id', 'unidad_entrante_id']
      });
    }

    const tiposValidos = ['UNIDAD_COMPLETA', 'CRUZADO'];
    if (!tiposValidos.includes(tipo_relevo)) {
      return res.status(400).json({
        error: 'Tipo de relevo inválido',
        tipos_validos: tiposValidos
      });
    }

    const relevo = await SalidaModel.registrarRelevo({
      situacion_id,
      tipo_relevo,
      unidad_saliente_id,
      unidad_entrante_id,
      brigadistas_salientes: brigadistas_salientes || [],
      brigadistas_entrantes: brigadistas_entrantes || [],
      observaciones,
      registrado_por: req.user.userId
    });

    return res.status(201).json({
      message: 'Relevo registrado exitosamente',
      relevo
    });
  } catch (error) {
    console.error('Error en registrarRelevo:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/salidas/relevos/:situacionId
 * Obtener relevos de una situación
 */
export async function getRelevos(req: Request, res: Response) {
  try {
    const { situacionId } = req.params;

    const relevos = await SalidaModel.getRelevosBySituacion(parseInt(situacionId));

    return res.json({
      situacion_id: parseInt(situacionId),
      relevos,
      total: relevos.length
    });
  } catch (error) {
    console.error('Error en getRelevos:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}
