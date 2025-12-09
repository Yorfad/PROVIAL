import { Request, Response } from 'express';
import { SituacionModel, DetalleSituacionModel } from '../models/situacion.model';
import { TurnoModel } from '../models/turno.model';
import { UsuarioModel } from '../models/usuario.model';
import { db } from '../config/database';

// ========================================
// HELPERS
// ========================================

/**
 * Obtener IDs de unidades que el usuario puede ver según su sede
 */
async function getUnidadesPermitidas(userId: number, rol: string): Promise<number[] | null> {
  // COP, ADMIN y OPERACIONES pueden ver todas las unidades
  if (rol === 'COP' || rol === 'ADMIN' || rol === 'OPERACIONES') {
    return null; // null = todas las unidades
  }

  // Obtener usuario con su sede
  const usuario = await UsuarioModel.findById(userId);

  if (!usuario || !usuario.sede_id) {
    return []; // Sin sede = no puede ver ninguna unidad
  }

  // Obtener unidades de la misma sede
  const result = await db.manyOrNone(
    'SELECT id FROM unidad WHERE sede_id = $1 AND activa = true',
    [usuario.sede_id]
  );

  return result.map((r: any) => r.id);
}

// ========================================
// CREAR SITUACIÓN
// ========================================

export async function createSituacion(req: Request, res: Response) {
  try {
    const {
      tipo_situacion,
      unidad_id,
      turno_id,
      asignacion_id,
      ruta_id,
      km,
      sentido,
      latitud,
      longitud,
      ubicacion_manual,
      combustible,
      combustible_fraccion,
      kilometraje_unidad,
      tripulacion_confirmada,
      descripcion,
      observaciones,
      incidente_id,
      detalles, // Array opcional de detalles
    } = req.body;

    const userId = req.user!.userId;

    // Si es un brigada, intentar obtener su asignación automáticamente
    let unidadFinal = unidad_id;
    let turnoFinal = turno_id;
    let asignacionFinal = asignacion_id;

    if (req.user!.rol === 'BRIGADA' && !unidad_id) {
      const miAsignacion = await TurnoModel.getMiAsignacionHoy(userId);
      if (miAsignacion) {
        unidadFinal = miAsignacion.unidad_id;
        turnoFinal = miAsignacion.turno_id;
        asignacionFinal = miAsignacion.asignacion_id;
      }
    }

    // Validar que tengamos unidad_id
    if (!unidadFinal) {
      return res.status(400).json({ error: 'unidad_id es requerido' });
    }

    // Crear la situación
    const situacion = await SituacionModel.create({
      tipo_situacion,
      unidad_id: unidadFinal,
      turno_id: turnoFinal,
      asignacion_id: asignacionFinal,
      ruta_id,
      km,
      sentido,
      latitud,
      longitud,
      ubicacion_manual,
      combustible,
      combustible_fraccion,
      kilometraje_unidad,
      tripulacion_confirmada,
      descripcion,
      observaciones,
      incidente_id,
      creado_por: userId,
    });

    // Agregar detalles si fueron proporcionados
    if (detalles && Array.isArray(detalles)) {
      for (const detalle of detalles) {
        await DetalleSituacionModel.create({
          situacion_id: situacion.id,
          tipo_detalle: detalle.tipo_detalle,
          datos: detalle.datos,
          creado_por: userId,
        });
      }
    }

    // Obtener la situación completa para devolver
    const situacionCompleta = await SituacionModel.getById(situacion.id);

    // TODO: Emitir evento WebSocket para tiempo real
    // io.to('cop').emit('situacion:nueva', situacionCompleta);

    return res.status(201).json({
      message: 'Situación creada exitosamente',
      situacion: situacionCompleta,
    });
  } catch (error) {
    console.error('Error en createSituacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// OBTENER SITUACIÓN POR ID/UUID
// ========================================

export async function getSituacion(req: Request, res: Response) {
  try {
    const { id } = req.params;

    let situacion;

    // Intentar obtener por UUID primero, luego por ID
    if (id.includes('-')) {
      situacion = await SituacionModel.getByUuid(id);
    } else {
      situacion = await SituacionModel.getById(parseInt(id, 10));
    }

    if (!situacion) {
      return res.status(404).json({ error: 'Situación no encontrada' });
    }

    return res.json({ situacion });
  } catch (error) {
    console.error('Error en getSituacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// LISTAR SITUACIONES
// ========================================

export async function listSituaciones(req: Request, res: Response) {
  try {
    const {
      unidad_id,
      turno_id,
      tipo_situacion,
      estado,
      fecha_desde,
      fecha_hasta,
      activas_solo,
      limit,
      offset,
    } = req.query;

    const filters: any = {};

    if (unidad_id) filters.unidad_id = parseInt(unidad_id as string, 10);
    if (turno_id) filters.turno_id = parseInt(turno_id as string, 10);
    if (tipo_situacion) filters.tipo_situacion = tipo_situacion as string;
    if (estado) filters.estado = estado as string;
    if (fecha_desde) filters.fecha_desde = new Date(fecha_desde as string);
    if (fecha_hasta) filters.fecha_hasta = new Date(fecha_hasta as string);
    if (limit) filters.limit = parseInt(limit as string, 10);
    if (offset) filters.offset = parseInt(offset as string, 10);

    // Aplicar filtro de sede para usuarios que no sean COP/ADMIN
    const unidadesPermitidas = await getUnidadesPermitidas(req.user!.userId, req.user!.rol);

    let situaciones;

    if (activas_solo === 'true') {
      situaciones = await SituacionModel.getActivas(filters);
    } else {
      situaciones = await SituacionModel.list(filters);
    }

    // Filtrar situaciones por unidades permitidas
    if (unidadesPermitidas !== null) {
      situaciones = situaciones.filter((s: any) => unidadesPermitidas.includes(s.unidad_id));
    }

    return res.json({ situaciones, count: situaciones.length });
  } catch (error) {
    console.error('Error en listSituaciones:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// SITUACIONES DE MI UNIDAD HOY (APP MÓVIL)
// ========================================

export async function getMiUnidadHoy(req: Request, res: Response) {
  try {
    const userId = req.user!.userId;

    // Obtener asignación del usuario
    const miAsignacion = await TurnoModel.getMiAsignacionHoy(userId);

    if (!miAsignacion) {
      return res.json({
        message: 'No tienes asignación para hoy',
        situaciones: [],
      });
    }

    // Obtener situaciones de la unidad
    const situaciones = await SituacionModel.getMiUnidadHoy(miAsignacion.unidad_id);

    return res.json({ situaciones, asignacion: miAsignacion });
  } catch (error) {
    console.error('Error en getMiUnidadHoy:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// BITÁCORA DE UNIDAD
// ========================================

export async function getBitacoraUnidad(req: Request, res: Response) {
  try {
    const { unidad_id } = req.params;
    const { fecha_desde, fecha_hasta, limit } = req.query;

    const filters: any = {};

    if (fecha_desde) filters.fecha_desde = new Date(fecha_desde as string);
    if (fecha_hasta) filters.fecha_hasta = new Date(fecha_hasta as string);
    if (limit) filters.limit = parseInt(limit as string, 10);

    const bitacora = await SituacionModel.getBitacoraUnidad(parseInt(unidad_id, 10), filters);

    return res.json({ bitacora, count: bitacora.length });
  } catch (error) {
    console.error('Error en getBitacoraUnidad:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// MAPA - ÚLTIMA SITUACIÓN POR UNIDAD
// ========================================

export async function getMapaSituaciones(req: Request, res: Response) {
  try {
    // Aplicar filtro de sede para usuarios que no sean COP/ADMIN
    const unidadesPermitidas = await getUnidadesPermitidas(req.user!.userId, req.user!.rol);

    let unidades = await SituacionModel.getUltimaSituacionPorUnidad();

    // Filtrar unidades por sede si es necesario
    if (unidadesPermitidas !== null) {
      unidades = unidades.filter((u: any) => unidadesPermitidas.includes(u.unidad_id));
    }

    return res.json({ unidades, count: unidades.length });
  } catch (error) {
    console.error('Error en getMapaSituaciones:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// ACTUALIZAR SITUACIÓN
// ========================================

export async function updateSituacion(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const {
      tipo_situacion,
      estado,
      ruta_id,
      km,
      sentido,
      latitud,
      longitud,
      combustible,
      combustible_fraccion,
      kilometraje_unidad,
      descripcion,
      observaciones,
    } = req.body;

    const situacion = await SituacionModel.update(parseInt(id, 10), {
      tipo_situacion,
      estado,
      ruta_id,
      km,
      sentido,
      latitud,
      longitud,
      combustible,
      combustible_fraccion,
      kilometraje_unidad,
      descripcion,
      observaciones,
      actualizado_por: userId,
    });

    // Obtener situación completa
    const situacionCompleta = await SituacionModel.getById(situacion.id);

    // TODO: Emitir evento WebSocket
    // io.to('cop').emit('situacion:actualizada', situacionCompleta);

    return res.json({
      message: 'Situación actualizada exitosamente',
      situacion: situacionCompleta,
    });
  } catch (error) {
    console.error('Error en updateSituacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// CERRAR SITUACIÓN
// ========================================

export async function cerrarSituacion(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { observaciones_finales } = req.body;
    const userId = req.user!.userId;

    const situacion = await SituacionModel.cerrar(parseInt(id, 10), userId, observaciones_finales);

    // Obtener situación completa
    const situacionCompleta = await SituacionModel.getById(situacion.id);

    // TODO: Emitir evento WebSocket
    // io.to('cop').emit('situacion:cerrada', situacionCompleta);

    return res.json({
      message: 'Situación cerrada exitosamente',
      situacion: situacionCompleta,
    });
  } catch (error) {
    console.error('Error en cerrarSituacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// ELIMINAR SITUACIÓN (ADMIN)
// ========================================

export async function deleteSituacion(req: Request, res: Response) {
  try {
    const { id } = req.params;

    await SituacionModel.delete(parseInt(id, 10));

    return res.json({ message: 'Situación eliminada exitosamente' });
  } catch (error) {
    console.error('Error en deleteSituacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// DETALLES DE SITUACIÓN
// ========================================

/**
 * Crear detalle de situación
 */
export async function createDetalle(req: Request, res: Response) {
  try {
    const { id: situacion_id } = req.params;
    const { tipo_detalle, datos } = req.body;
    const userId = req.user!.userId;

    const detalle = await DetalleSituacionModel.create({
      situacion_id: parseInt(situacion_id, 10),
      tipo_detalle,
      datos,
      creado_por: userId,
    });

    return res.status(201).json({
      message: 'Detalle creado exitosamente',
      detalle,
    });
  } catch (error) {
    console.error('Error en createDetalle:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * Listar detalles de una situación
 */
export async function getDetalles(req: Request, res: Response) {
  try {
    const { id: situacion_id } = req.params;

    const detalles = await DetalleSituacionModel.getBySituacionId(parseInt(situacion_id, 10));

    return res.json({ detalles, count: detalles.length });
  } catch (error) {
    console.error('Error en getDetalles:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * Actualizar detalle
 */
export async function updateDetalle(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { datos } = req.body;

    const detalle = await DetalleSituacionModel.update(parseInt(id, 10), datos);

    return res.json({
      message: 'Detalle actualizado exitosamente',
      detalle,
    });
  } catch (error) {
    console.error('Error en updateDetalle:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

/**
 * Eliminar detalle
 */
export async function deleteDetalle(req: Request, res: Response) {
  try {
    const { id } = req.params;

    await DetalleSituacionModel.delete(parseInt(id, 10));

    return res.json({ message: 'Detalle eliminado exitosamente' });
  } catch (error) {
    console.error('Error en deleteDetalle:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}

// ========================================
// RESUMEN DE UNIDADES (DASHBOARD)
// ========================================

/**
 * Obtener resumen de todas las unidades con su estado actual
 * Incluye: última situación, km, ruta activa, combustible, sentido, hora de reporte
 */
export async function getResumenUnidades(req: Request, res: Response) {
  try {
    // Aplicar filtro de sede para usuarios que no sean COP/ADMIN
    const unidadesPermitidas = await getUnidadesPermitidas(req.user!.userId, req.user!.rol);

    const query = `
      SELECT
        u.id as unidad_id,
        u.codigo as unidad_codigo,
        u.tipo_unidad,
        u.placa,
        s.nombre as sede_nombre,

        -- Última situación
        us.situacion_id,
        us.situacion_uuid,
        us.tipo_situacion,
        us.estado as situacion_estado,
        us.km,
        us.sentido,
        us.ruta_codigo,
        us.ruta_nombre,
        us.latitud,
        us.longitud,
        us.combustible,
        us.combustible_fraccion,
        us.kilometraje_unidad,
        us.descripcion as situacion_descripcion,
        us.situacion_fecha,

        -- Ruta activa
        au.ruta_activa_id,
        ra.codigo as ruta_activa_codigo,
        ra.nombre as ruta_activa_nombre,
        au.hora_ultima_actualizacion_ruta,

        -- Información de turno
        t.id as turno_id,
        t.fecha as turno_fecha,
        t.estado as turno_estado,
        au.hora_salida_real,
        au.hora_entrada_real,

        -- Tripulación
        COALESCE(
          json_agg(
            json_build_object(
              'usuario_id', tt_u.id,
              'nombre_completo', tt_u.nombre_completo,
              'rol_tripulacion', tt.rol_tripulacion
            ) ORDER BY tt.rol_tripulacion
          ) FILTER (WHERE tt.id IS NOT NULL),
          '[]'
        ) as tripulacion

      FROM unidad u
      LEFT JOIN sede s ON u.sede_id = s.id
      LEFT JOIN v_ultima_situacion_unidad us ON u.id = us.unidad_id
      LEFT JOIN asignacion_unidad au ON u.id = au.unidad_id
        AND au.turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)
      LEFT JOIN turno t ON au.turno_id = t.id
      LEFT JOIN ruta ra ON au.ruta_activa_id = ra.id
      LEFT JOIN tripulacion_turno tt ON au.id = tt.asignacion_id
      LEFT JOIN usuario tt_u ON tt.usuario_id = tt_u.id
      WHERE u.activa = true
        ${unidadesPermitidas !== null ? 'AND u.id = ANY($1::int[])' : ''}
      GROUP BY
        u.id, u.codigo, u.tipo_unidad, u.placa, s.nombre,
        us.situacion_id, us.situacion_uuid, us.tipo_situacion, us.estado,
        us.km, us.sentido, us.ruta_codigo, us.ruta_nombre, us.latitud, us.longitud,
        us.combustible, us.combustible_fraccion, us.kilometraje_unidad,
        us.descripcion, us.situacion_fecha,
        au.ruta_activa_id, ra.codigo, ra.nombre, au.hora_ultima_actualizacion_ruta,
        t.id, t.fecha, t.estado, au.hora_salida_real, au.hora_entrada_real
      ORDER BY u.codigo
    `;

    const params = unidadesPermitidas !== null ? [unidadesPermitidas] : [];
    const resumen = await db.manyOrNone(query, params);

    return res.json({
      resumen,
      count: resumen.length,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error en getResumenUnidades:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}
