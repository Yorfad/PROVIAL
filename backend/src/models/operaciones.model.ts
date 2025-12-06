import { db } from '../config/database';

// ========================================
// INTERFACES
// ========================================

export interface EstadisticasBrigada {
  usuario_id: number;
  nombre_completo: string;
  chapa: string;
  telefono: string | null;
  sede_id: number;
  sede_nombre: string;
  rol_nombre: string;
  turnos_ultimo_mes: number;
  turnos_ultimo_trimestre: number;
  ultimo_turno_fecha: Date | null;
  dias_desde_ultimo_turno: number | null;
  proximo_turno_fecha: Date | null;
  rol_tripulacion_frecuente: string | null;
  activo: boolean;
}

export interface EstadisticasUnidad {
  unidad_id: number;
  unidad_codigo: string;
  tipo_unidad: string;
  marca: string | null;
  modelo: string | null;
  sede_id: number;
  sede_nombre: string;
  activa: boolean;
  combustible_actual: number;
  capacidad_combustible: number | null;
  odometro_actual: number;
  turnos_ultimo_mes: number;
  turnos_ultimo_trimestre: number;
  ultimo_turno_fecha: Date | null;
  dias_desde_ultimo_uso: number | null;
  proximo_turno_fecha: Date | null;
  consumo_promedio_diario: number | null;
  rendimiento_promedio: number | null;
  km_ultimo_mes: number | null;
}

export interface DisponibilidadRecursos {
  sede_id: number;
  sede_nombre: string;
  total_brigadas_activas: number;
  brigadas_en_turno_hoy: number;
  total_unidades_activas: number;
  unidades_en_turno_hoy: number;
  brigadas_disponibles_hoy: number;
  unidades_disponibles_hoy: number;
}

export interface ValidacionBrigada {
  disponible: boolean;
  mensaje: string;
  ultimo_turno_fecha: Date | null;
  dias_descanso: number;
}

export interface ValidacionUnidad {
  disponible: boolean;
  mensaje: string;
  ultimo_uso_fecha: Date | null;
  dias_descanso: number;
  combustible_suficiente: boolean;
}

export interface CombustibleRegistro {
  id: number;
  unidad_id: number;
  asignacion_id: number | null;
  turno_id: number | null;
  tipo: 'INICIAL' | 'RECARGA' | 'FINAL' | 'AJUSTE';
  combustible_anterior: number;
  combustible_agregado: number;
  combustible_nuevo: number;
  combustible_consumido: number | null;
  odometro_anterior: number | null;
  odometro_actual: number | null;
  km_recorridos: number | null;
  rendimiento_km_litro: number | null;
  observaciones: string | null;
  registrado_por: number;
  created_at: Date;
}

export interface CreateCombustibleDTO {
  unidad_id: number;
  asignacion_id?: number;
  turno_id?: number;
  tipo: 'INICIAL' | 'RECARGA' | 'FINAL' | 'AJUSTE';
  combustible_anterior: number;
  combustible_agregado?: number;
  combustible_nuevo: number;
  combustible_consumido?: number;
  odometro_anterior?: number;
  odometro_actual?: number;
  km_recorridos?: number;
  observaciones?: string;
  registrado_por: number;
}

// ========================================
// MODEL
// ========================================

export const OperacionesModel = {
  // ========================================
  // ESTADÍSTICAS DE BRIGADAS
  // ========================================

  async getEstadisticasBrigadas(sedeId?: number): Promise<EstadisticasBrigada[]> {
    let query = 'SELECT * FROM v_estadisticas_brigadas';
    const params: any[] = [];

    if (sedeId) {
      query += ' WHERE sede_id = $1';
      params.push(sedeId);
    }

    query += ' ORDER BY nombre_completo';

    return db.manyOrNone(query, params);
  },

  async getEstadisticasBrigada(usuarioId: number): Promise<EstadisticasBrigada | null> {
    return db.oneOrNone(
      'SELECT * FROM v_estadisticas_brigadas WHERE usuario_id = $1',
      [usuarioId]
    );
  },

  // ========================================
  // ESTADÍSTICAS DE UNIDADES
  // ========================================

  async getEstadisticasUnidades(sedeId?: number): Promise<EstadisticasUnidad[]> {
    let query = 'SELECT * FROM v_estadisticas_unidades';
    const params: any[] = [];

    if (sedeId) {
      query += ' WHERE sede_id = $1';
      params.push(sedeId);
    }

    query += ' ORDER BY unidad_codigo';

    return db.manyOrNone(query, params);
  },

  async getEstadisticasUnidad(unidadId: number): Promise<EstadisticasUnidad | null> {
    return db.oneOrNone(
      'SELECT * FROM v_estadisticas_unidades WHERE unidad_id = $1',
      [unidadId]
    );
  },

  // ========================================
  // DISPONIBILIDAD DE RECURSOS
  // ========================================

  async getDisponibilidadRecursos(sedeId?: number): Promise<DisponibilidadRecursos[]> {
    let query = 'SELECT * FROM v_disponibilidad_recursos';
    const params: any[] = [];

    if (sedeId) {
      query += ' WHERE sede_id = $1';
      params.push(sedeId);
    }

    query += ' ORDER BY sede_nombre';

    return db.manyOrNone(query, params);
  },

  // ========================================
  // VALIDACIONES
  // ========================================

  async validarDisponibilidadBrigada(
    usuarioId: number,
    fecha: string
  ): Promise<ValidacionBrigada> {
    const result = await db.oneOrNone(
      'SELECT * FROM validar_disponibilidad_brigada($1, $2)',
      [usuarioId, fecha]
    );

    return result || {
      disponible: true,
      mensaje: 'Brigada disponible',
      ultimo_turno_fecha: null,
      dias_descanso: 999,
    };
  },

  async validarDisponibilidadUnidad(
    unidadId: number,
    fecha: string
  ): Promise<ValidacionUnidad> {
    const result = await db.oneOrNone(
      'SELECT * FROM validar_disponibilidad_unidad($1, $2)',
      [unidadId, fecha]
    );

    return result || {
      disponible: false,
      mensaje: 'No se pudo validar unidad',
      ultimo_uso_fecha: null,
      dias_descanso: 0,
      combustible_suficiente: false,
    };
  },

  // ========================================
  // COMBUSTIBLE
  // ========================================

  async registrarCombustible(data: CreateCombustibleDTO): Promise<CombustibleRegistro> {
    // Calcular rendimiento si es tipo FINAL
    let rendimiento_km_litro = null;
    if (data.tipo === 'FINAL' && data.km_recorridos && data.combustible_consumido) {
      if (data.combustible_consumido > 0) {
        rendimiento_km_litro = data.km_recorridos / data.combustible_consumido;
      }
    }

    return db.one(
      `INSERT INTO combustible_registro (
        unidad_id, asignacion_id, turno_id, tipo,
        combustible_anterior, combustible_agregado, combustible_nuevo, combustible_consumido,
        odometro_anterior, odometro_actual, km_recorridos,
        rendimiento_km_litro, observaciones, registrado_por
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *`,
      [
        data.unidad_id,
        data.asignacion_id || null,
        data.turno_id || null,
        data.tipo,
        data.combustible_anterior,
        data.combustible_agregado || 0,
        data.combustible_nuevo,
        data.combustible_consumido || null,
        data.odometro_anterior || null,
        data.odometro_actual || null,
        data.km_recorridos || null,
        rendimiento_km_litro,
        data.observaciones || null,
        data.registrado_por,
      ]
    );
  },

  async getHistorialCombustible(
    unidadId: number,
    limit: number = 50
  ): Promise<CombustibleRegistro[]> {
    return db.manyOrNone(
      `SELECT * FROM combustible_registro
       WHERE unidad_id = $1
       ORDER BY created_at DESC
       LIMIT $2`,
      [unidadId, limit]
    );
  },

  async getHistorialCombustiblePorTurno(
    turnoId: number
  ): Promise<CombustibleRegistro[]> {
    return db.manyOrNone(
      `SELECT * FROM combustible_registro
       WHERE turno_id = $1
       ORDER BY created_at`,
      [turnoId]
    );
  },

  async getHistorialCombustiblePorAsignacion(
    asignacionId: number
  ): Promise<CombustibleRegistro[]> {
    return db.manyOrNone(
      `SELECT * FROM combustible_registro
       WHERE asignacion_id = $1
       ORDER BY created_at`,
      [asignacionId]
    );
  },

  // ========================================
  // BRIGADAS DISPONIBLES PARA FECHA
  // ========================================

  async getBrigadasDisponibles(fecha: string, sedeId?: number): Promise<any[]> {
    let query = `
      SELECT
        u.id,
        u.nombre_completo,
        u.chapa,
        u.telefono,
        u.sede_id,
        s.nombre as sede_nombre,
        eb.turnos_ultimo_mes,
        eb.ultimo_turno_fecha,
        eb.dias_desde_ultimo_turno,
        eb.rol_tripulacion_frecuente,
        v.disponible,
        v.mensaje,
        v.dias_descanso
      FROM usuario u
      INNER JOIN rol r ON u.rol_id = r.id
      INNER JOIN sede s ON u.sede_id = s.id
      LEFT JOIN v_estadisticas_brigadas eb ON u.id = eb.usuario_id
      CROSS JOIN LATERAL validar_disponibilidad_brigada(u.id, $1::DATE) v
      WHERE r.nombre = 'BRIGADA'
        AND u.activo = TRUE
    `;

    const params: any[] = [fecha];

    if (sedeId) {
      query += ' AND u.sede_id = $2';
      params.push(sedeId);
    }

    query += ' ORDER BY v.disponible DESC, v.dias_descanso DESC, u.nombre_completo';

    return db.manyOrNone(query, params);
  },

  // ========================================
  // UNIDADES DISPONIBLES PARA FECHA
  // ========================================

  async getUnidadesDisponibles(fecha: string, sedeId?: number): Promise<any[]> {
    let query = `
      SELECT
        un.id,
        un.codigo,
        un.tipo_unidad,
        un.marca,
        un.modelo,
        un.sede_id,
        s.nombre as sede_nombre,
        un.combustible_actual,
        un.capacidad_combustible,
        un.odometro_actual,
        eu.turnos_ultimo_mes,
        eu.ultimo_turno_fecha,
        eu.dias_desde_ultimo_uso,
        v.disponible,
        v.mensaje,
        v.dias_descanso,
        v.combustible_suficiente
      FROM unidad un
      INNER JOIN sede s ON un.sede_id = s.id
      LEFT JOIN v_estadisticas_unidades eu ON un.id = eu.unidad_id
      CROSS JOIN LATERAL validar_disponibilidad_unidad(un.id, $1::DATE) v
      WHERE un.activa = TRUE
    `;

    const params: any[] = [fecha];

    if (sedeId) {
      query += ' AND un.sede_id = $2';
      params.push(sedeId);
    }

    query += ' ORDER BY v.disponible DESC, un.combustible_actual DESC, un.codigo';

    return db.manyOrNone(query, params);
  },
};
