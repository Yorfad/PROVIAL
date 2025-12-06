import { Request, Response } from 'express';
import { SalidaModel } from '../models/salida.model';

// ========================================
// REGISTRO DE INGRESOS
// ========================================

/**
 * POST /api/ingresos/registrar
 * Registrar ingreso a sede (temporal o final)
 */
export async function registrarIngreso(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const {
      sede_id,
      tipo_ingreso,
      km_ingreso,
      combustible_ingreso,
      observaciones,
      es_ingreso_final
    } = req.body;

    // Validar campos requeridos
    if (!tipo_ingreso || !sede_id) {
      return res.status(400).json({
        error: 'Campos requeridos faltantes',
        required: ['tipo_ingreso', 'sede_id']
      });
    }

    // Validar tipos de ingreso
    const tiposValidos = ['COMBUSTIBLE', 'COMISION', 'APOYO', 'ALMUERZO', 'MANTENIMIENTO', 'FINALIZACION', 'FINALIZAR_JORNADA'];
    if (!tiposValidos.includes(tipo_ingreso)) {
      return res.status(400).json({
        error: 'Tipo de ingreso inválido',
        tipos_validos: tiposValidos
      });
    }

    // Obtener mi salida activa
    const miSalida = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (!miSalida) {
      return res.status(404).json({
        error: 'No tienes salida activa',
        message: 'Debes tener una salida activa para registrar un ingreso'
      });
    }

    // Registrar ingreso
    const ingresoId = await SalidaModel.registrarIngreso({
      salida_id: miSalida.salida_id,
      sede_id,
      tipo_ingreso,
      km_ingreso,
      combustible_ingreso,
      observaciones,
      es_ingreso_final: es_ingreso_final || false,
      registrado_por: req.user.userId
    });

    // Obtener el ingreso creado
    const ingreso = await SalidaModel.getIngresoById(ingresoId);

    return res.status(201).json({
      message: es_ingreso_final
        ? 'Día laboral finalizado exitosamente'
        : 'Ingreso a sede registrado exitosamente',
      ingreso,
      es_ingreso_final: es_ingreso_final || false,
      instruccion: es_ingreso_final
        ? 'La salida ha sido finalizada. Unidad y tripulación liberadas.'
        : 'Para volver a salir, registra una salida de sede.'
    });
  } catch (error: any) {
    console.error('Error en registrarIngreso:', error);

    if (error.message && error.message.includes('ya existe un ingreso activo')) {
      return res.status(409).json({
        error: 'Ya tienes un ingreso activo',
        message: 'Debes registrar salida de sede antes de ingresar nuevamente'
      });
    }

    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/ingresos/:id/salir
 * Registrar salida de sede (volver a la calle)
 */
export async function registrarSalidaDeSede(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { id } = req.params;
    const { km_salida, combustible_salida, observaciones } = req.body;

    // Verificar que el ingreso existe y es mío
    const ingreso = await SalidaModel.getIngresoById(parseInt(id));

    if (!ingreso) {
      return res.status(404).json({ error: 'Ingreso no encontrado' });
    }

    // Verificar que el ingreso pertenece a mi salida activa
    const miSalida = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (!miSalida || ingreso.salida_unidad_id !== miSalida.salida_id) {
      return res.status(403).json({
        error: 'No autorizado',
        message: 'Este ingreso no pertenece a tu salida activa'
      });
    }

    // Verificar que no sea ingreso final
    if (ingreso.es_ingreso_final) {
      return res.status(400).json({
        error: 'No se puede salir de un ingreso final',
        message: 'El ingreso final marca el fin de la jornada laboral'
      });
    }

    // Registrar salida de sede
    const success = await SalidaModel.registrarSalidaDeSede({
      ingreso_id: parseInt(id),
      km_salida,
      combustible_salida,
      observaciones
    });

    if (!success) {
      return res.status(400).json({
        error: 'No se pudo registrar la salida',
        message: 'Verifica que el ingreso esté activo'
      });
    }

    // Obtener ingreso actualizado
    const ingresoActualizado = await SalidaModel.getIngresoById(parseInt(id));

    return res.json({
      message: 'Salida de sede registrada exitosamente',
      ingreso: ingresoActualizado,
      instruccion: 'Puedes continuar patrullando y registrando situaciones'
    });
  } catch (error) {
    console.error('Error en registrarSalidaDeSede:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// CONSULTAS DE INGRESOS
// ========================================

/**
 * GET /api/ingresos/mi-ingreso-activo
 * Obtener mi ingreso activo (si estoy ingresado)
 */
export async function getMiIngresoActivo(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    // Obtener mi salida activa
    const miSalida = await SalidaModel.getMiSalidaActiva(req.user.userId);

    if (!miSalida) {
      return res.status(404).json({
        error: 'No tienes salida activa'
      });
    }

    // Obtener ingreso activo
    const ingresoActivo = await SalidaModel.getIngresoActivo(miSalida.salida_id);

    if (!ingresoActivo) {
      return res.status(404).json({
        error: 'No tienes ingreso activo',
        message: 'Estás en la calle, no en sede'
      });
    }

    return res.json(ingresoActivo);
  } catch (error) {
    console.error('Error en getMiIngresoActivo:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/ingresos/historial/:salidaId
 * Obtener historial de ingresos de una salida
 */
export async function getHistorialIngresos(req: Request, res: Response) {
  try {
    const { salidaId } = req.params;

    const historial = await SalidaModel.getHistorialIngresos(parseInt(salidaId));

    return res.json({
      salida_id: parseInt(salidaId),
      ingresos: historial,
      total: historial.length
    });
  } catch (error) {
    console.error('Error en getHistorialIngresos:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/ingresos/:id
 * Obtener información de un ingreso específico
 */
export async function getIngreso(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const ingreso = await SalidaModel.getIngresoById(parseInt(id));

    if (!ingreso) {
      return res.status(404).json({ error: 'Ingreso no encontrado' });
    }

    return res.json(ingreso);
  } catch (error) {
    console.error('Error en getIngreso:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}
