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
