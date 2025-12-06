import { Request, Response } from 'express';
import { SalidaModel } from '../models/salida.model';

// ========================================
// CONSULTAS DE SEDES
// ========================================

/**
 * GET /api/sedes
 * Obtener todas las sedes activas
 */
export async function getSedes(_req: Request, res: Response) {
  try {
    const sedes = await SalidaModel.getSedes();

    return res.json({
      sedes,
      total: sedes.length
    });
  } catch (error) {
    console.error('Error en getSedes:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/sedes/:id
 * Obtener información de una sede
 */
export async function getSede(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const sede = await SalidaModel.getSedeById(parseInt(id));

    if (!sede) {
      return res.status(404).json({ error: 'Sede no encontrada' });
    }

    return res.json(sede);
  } catch (error) {
    console.error('Error en getSede:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/sedes/:id/unidades
 * Obtener unidades de una sede (considerando reasignaciones)
 */
export async function getUnidadesDeSede(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const unidades = await SalidaModel.getUnidadesDeSede(parseInt(id));

    return res.json({
      sede_id: parseInt(id),
      unidades,
      total: unidades.length
    });
  } catch (error) {
    console.error('Error en getUnidadesDeSede:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/sedes/:id/personal
 * Obtener personal de una sede (considerando reasignaciones)
 */
export async function getPersonalDeSede(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const personal = await SalidaModel.getPersonalDeSede(parseInt(id));

    return res.json({
      sede_id: parseInt(id),
      personal,
      total: personal.length
    });
  } catch (error) {
    console.error('Error en getPersonalDeSede:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/sedes/mi-sede
 * Obtener mi sede efectiva (considerando reasignaciones)
 */
export async function getMiSede(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    // Obtener mi unidad asignada (que incluye sede)
    const miUnidad: any = await SalidaModel.getMiUnidadAsignada(req.user.userId);

    if (!miUnidad) {
      return res.status(404).json({
        error: 'No tienes unidad asignada'
      });
    }

    // Retornar información de mi sede
    return res.json({
      mi_sede_id: miUnidad.mi_sede_id,
      mi_sede_codigo: miUnidad.mi_sede_codigo,
      mi_sede_nombre: miUnidad.mi_sede_nombre,
      unidad_sede_id: miUnidad.unidad_sede_id,
      unidad_sede_codigo: miUnidad.unidad_sede_codigo,
      unidad_sede_nombre: miUnidad.unidad_sede_nombre
    });
  } catch (error) {
    console.error('Error en getMiSede:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// REASIGNACIONES
// ========================================

/**
 * POST /api/sedes/reasignaciones
 * Crear reasignación de personal o unidad entre sedes
 */
export async function crearReasignacion(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const {
      tipo,
      recurso_id,
      sede_origen_id,
      sede_destino_id,
      fecha_inicio,
      fecha_fin,
      es_permanente,
      motivo
    } = req.body;

    // Validar campos requeridos
    if (!tipo || !recurso_id || !sede_origen_id || !sede_destino_id || !fecha_inicio) {
      return res.status(400).json({
        error: 'Campos requeridos faltantes',
        required: ['tipo', 'recurso_id', 'sede_origen_id', 'sede_destino_id', 'fecha_inicio']
      });
    }

    // Validar tipos
    const tiposValidos = ['USUARIO', 'UNIDAD'];
    if (!tiposValidos.includes(tipo)) {
      return res.status(400).json({
        error: 'Tipo inválido',
        tipos_validos: tiposValidos
      });
    }

    // Verificar que el usuario tenga permiso sobre la sede origen
    const tienePermiso = await SalidaModel.tienePermisoSede(req.user.userId, sede_origen_id);

    if (!tienePermiso) {
      return res.status(403).json({
        error: 'No autorizado',
        message: 'No tienes permiso sobre la sede de origen'
      });
    }

    // Crear reasignación
    const reasignacion = await SalidaModel.crearReasignacion({
      tipo,
      recurso_id,
      sede_origen_id,
      sede_destino_id,
      fecha_inicio,
      fecha_fin,
      es_permanente: es_permanente || false,
      motivo,
      autorizado_por: req.user.userId
    });

    return res.status(201).json({
      message: 'Reasignación creada exitosamente',
      reasignacion
    });
  } catch (error) {
    console.error('Error en crearReasignacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * GET /api/sedes/reasignaciones/activas
 * Obtener reasignaciones activas
 */
export async function getReasignacionesActivas(_req: Request, res: Response) {
  try {
    const reasignaciones = await SalidaModel.getReasignacionesActivas();

    return res.json({
      reasignaciones,
      total: reasignaciones.length
    });
  } catch (error) {
    console.error('Error en getReasignacionesActivas:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * POST /api/sedes/reasignaciones/:id/finalizar
 * Finalizar una reasignación
 */
export async function finalizarReasignacion(req: Request, res: Response) {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const { id } = req.params;

    const reasignacion = await SalidaModel.finalizarReasignacion(parseInt(id));

    return res.json({
      message: 'Reasignación finalizada exitosamente',
      reasignacion
    });
  } catch (error) {
    console.error('Error en finalizarReasignacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}
