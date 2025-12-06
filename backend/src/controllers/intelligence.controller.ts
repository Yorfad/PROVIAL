import { Request, Response } from 'express';
import { db } from '../config/database';

// ========================================
// VEHÍCULOS REINCIDENTES
// ========================================

export async function getVehiculosReincidentes(req: Request, res: Response) {
  try {
    const { limit = 20, nivel_riesgo } = req.query;

    let query = `
      SELECT * FROM mv_vehiculos_reincidentes
      WHERE 1=1
    `;

    const params: any[] = [];

    // Filtro por nivel de riesgo
    if (nivel_riesgo) {
      params.push(nivel_riesgo);
      query += ` AND nivel_riesgo >= $${params.length}`;
    }

    query += ` ORDER BY nivel_riesgo DESC, total_incidentes DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    const vehiculos = await db.manyOrNone(query, params);

    res.json({
      success: true,
      count: vehiculos.length,
      data: vehiculos
    });
  } catch (error) {
    console.error('Error obteniendo vehículos reincidentes:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo vehículos reincidentes',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// Buscar vehículo específico por placa
export async function getVehiculoByPlaca(req: Request, res: Response) {
  try {
    const { placa } = req.params;

    const vehiculo = await db.oneOrNone(
      `SELECT * FROM mv_vehiculos_reincidentes WHERE placa = $1`,
      [placa]
    );

    if (!vehiculo) {
      return res.status(404).json({
        success: false,
        message: 'Vehículo no encontrado en historial de reincidentes'
      });
    }

    return res.json({
      success: true,
      data: vehiculo
    });
  } catch (error) {
    console.error('Error buscando vehículo:', error);
    return res.status(500).json({
      success: false,
      message: 'Error buscando vehículo',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// ========================================
// PILOTOS PROBLEMÁTICOS
// ========================================

export async function getPilotosProblematicos(req: Request, res: Response) {
  try {
    const { limit = 20, nivel_riesgo, licencia_vencida } = req.query;

    let query = `
      SELECT * FROM mv_pilotos_problematicos
      WHERE 1=1
    `;

    const params: any[] = [];

    // Filtro por nivel de riesgo
    if (nivel_riesgo) {
      params.push(nivel_riesgo);
      query += ` AND nivel_riesgo >= $${params.length}`;
    }

    // Filtro por licencia vencida
    if (licencia_vencida === 'true') {
      query += ` AND licencia_vencida = TRUE`;
    }

    query += ` ORDER BY nivel_riesgo DESC, total_incidentes DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    const pilotos = await db.manyOrNone(query, params);

    res.json({
      success: true,
      count: pilotos.length,
      data: pilotos
    });
  } catch (error) {
    console.error('Error obteniendo pilotos problemáticos:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo pilotos problemáticos',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// Buscar piloto específico por licencia
export async function getPilotoByLicencia(req: Request, res: Response) {
  try {
    const { licencia } = req.params;

    const piloto = await db.oneOrNone(
      `SELECT * FROM mv_pilotos_problematicos WHERE licencia_numero = $1`,
      [licencia]
    );

    if (!piloto) {
      return res.status(404).json({
        success: false,
        message: 'Piloto no encontrado en historial de problemáticos'
      });
    }

    return res.json({
      success: true,
      data: piloto
    });
  } catch (error) {
    console.error('Error buscando piloto:', error);
    return res.status(500).json({
      success: false,
      message: 'Error buscando piloto',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// ========================================
// PUNTOS CALIENTES (HOTSPOTS)
// ========================================

export async function getPuntosCalientes(req: Request, res: Response) {
  try {
    const { limit = 50, ruta_codigo, nivel_peligrosidad } = req.query;

    let query = `
      SELECT * FROM mv_puntos_calientes
      WHERE 1=1
    `;

    const params: any[] = [];

    // Filtro por ruta
    if (ruta_codigo) {
      params.push(ruta_codigo);
      query += ` AND ruta_codigo = $${params.length}`;
    }

    // Filtro por nivel de peligrosidad
    if (nivel_peligrosidad) {
      params.push(nivel_peligrosidad);
      query += ` AND nivel_peligrosidad >= $${params.length}`;
    }

    query += ` ORDER BY nivel_peligrosidad DESC, total_incidentes DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    const puntos = await db.manyOrNone(query, params);

    res.json({
      success: true,
      count: puntos.length,
      data: puntos
    });
  } catch (error) {
    console.error('Error obteniendo puntos calientes:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo puntos calientes',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// Mapa de calor - todos los puntos para visualización
export async function getMapaCalor(_req: Request, res: Response) {
  try {
    const puntos = await db.manyOrNone(`
      SELECT
        ruta_codigo,
        ruta_nombre,
        kilometro,
        latitud_promedio,
        longitud_promedio,
        total_incidentes,
        nivel_peligrosidad
      FROM mv_puntos_calientes
      WHERE latitud_promedio IS NOT NULL
        AND longitud_promedio IS NOT NULL
      ORDER BY nivel_peligrosidad DESC
    `);

    res.json({
      success: true,
      count: puntos.length,
      data: puntos
    });
  } catch (error) {
    console.error('Error obteniendo mapa de calor:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo mapa de calor',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// ========================================
// TENDENCIAS TEMPORALES
// ========================================

export async function getTendenciasTemporales(req: Request, res: Response) {
  try {
    const { anio, mes } = req.query;

    let query = `SELECT * FROM mv_tendencias_temporales WHERE 1=1`;
    const params: any[] = [];

    // Filtro por año
    if (anio) {
      params.push(anio);
      query += ` AND anio = $${params.length}`;
    }

    // Filtro por mes
    if (mes) {
      params.push(mes);
      query += ` AND mes = $${params.length}`;
    }

    query += ` ORDER BY fecha DESC, hora DESC`;

    const tendencias = await db.manyOrNone(query, params);

    res.json({
      success: true,
      count: tendencias.length,
      data: tendencias
    });
  } catch (error) {
    console.error('Error obteniendo tendencias temporales:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo tendencias temporales',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// Análisis por día de la semana
export async function getAnalisisDiaSemana(_req: Request, res: Response) {
  try {
    const analisis = await db.manyOrNone(`
      SELECT
        dia_semana,
        nombre_dia,
        SUM(total_incidentes) as total_incidentes,
        SUM(total_heridos) as total_heridos,
        SUM(total_fallecidos) as total_fallecidos,
        AVG(total_incidentes) as promedio_incidentes
      FROM mv_tendencias_temporales
      GROUP BY dia_semana, nombre_dia
      ORDER BY dia_semana
    `);

    res.json({
      success: true,
      data: analisis
    });
  } catch (error) {
    console.error('Error obteniendo análisis por día:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo análisis por día',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// Análisis por franja horaria
export async function getAnalisisFranjaHoraria(_req: Request, res: Response) {
  try {
    const analisis = await db.manyOrNone(`
      SELECT
        franja_horaria,
        SUM(total_incidentes) as total_incidentes,
        SUM(total_heridos) as total_heridos,
        SUM(total_fallecidos) as total_fallecidos,
        AVG(total_incidentes) as promedio_incidentes
      FROM mv_tendencias_temporales
      GROUP BY franja_horaria
      ORDER BY
        CASE franja_horaria
          WHEN 'Madrugada (00:00-05:59)' THEN 1
          WHEN 'Mañana (06:00-11:59)' THEN 2
          WHEN 'Tarde (12:00-17:59)' THEN 3
          WHEN 'Noche (18:00-23:59)' THEN 4
        END
    `);

    res.json({
      success: true,
      data: analisis
    });
  } catch (error) {
    console.error('Error obteniendo análisis por franja horaria:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo análisis por franja horaria',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// ========================================
// DASHBOARD / RESUMEN
// ========================================

export async function getDashboard(_req: Request, res: Response) {
  try {
    // Obtener resumen de todas las vistas
    const [vehiculosTop, pilotosTop, puntosTop, tendenciasRecientes] = await Promise.all([
      db.manyOrNone(`SELECT * FROM mv_vehiculos_reincidentes ORDER BY nivel_riesgo DESC LIMIT 5`),
      db.manyOrNone(`SELECT * FROM mv_pilotos_problematicos ORDER BY nivel_riesgo DESC LIMIT 5`),
      db.manyOrNone(`SELECT * FROM mv_puntos_calientes ORDER BY nivel_peligrosidad DESC LIMIT 5`),
      db.manyOrNone(`
        SELECT * FROM mv_tendencias_temporales
        WHERE fecha >= CURRENT_DATE - INTERVAL '30 days'
        ORDER BY fecha DESC, hora DESC
        LIMIT 10
      `)
    ]);

    // Estadísticas generales
    const stats = await db.one(`
      SELECT
        (SELECT COUNT(*) FROM mv_vehiculos_reincidentes) as total_vehiculos_reincidentes,
        (SELECT COUNT(*) FROM mv_pilotos_problematicos) as total_pilotos_problematicos,
        (SELECT COUNT(*) FROM mv_puntos_calientes) as total_puntos_calientes,
        (SELECT COUNT(*) FROM vehiculo) as total_vehiculos_registrados,
        (SELECT COUNT(*) FROM piloto) as total_pilotos_registrados
    `);

    res.json({
      success: true,
      data: {
        estadisticas: stats,
        vehiculos_alto_riesgo: vehiculosTop,
        pilotos_alto_riesgo: pilotosTop,
        puntos_mas_peligrosos: puntosTop,
        tendencias_recientes: tendenciasRecientes
      }
    });
  } catch (error) {
    console.error('Error obteniendo dashboard:', error);
    res.status(500).json({
      success: false,
      message: 'Error obteniendo dashboard',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

// ========================================
// REFRESH DE VISTAS
// ========================================

export async function refreshViews(_req: Request, res: Response) {
  try {
    await db.none(`SELECT refresh_intelligence_views()`);

    res.json({
      success: true,
      message: 'Vistas de inteligencia refrescadas exitosamente'
    });
  } catch (error) {
    console.error('Error refrescando vistas:', error);
    res.status(500).json({
      success: false,
      message: 'Error refrescando vistas',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}
