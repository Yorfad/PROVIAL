import { db } from '../config/database';

export interface Piloto {
  id: number;
  nombre: string;
  licencia_tipo: 'A' | 'B' | 'C' | 'M' | 'E' | null;
  licencia_numero: bigint;
  licencia_vencimiento: Date | null;
  licencia_antiguedad: number | null;
  fecha_nacimiento: Date | null;
  etnia: string | null;
  total_incidentes: number;
  total_sanciones: number;
  primer_incidente: Date | null;
  ultimo_incidente: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface CreatePilotoDTO {
  nombre: string;
  licencia_tipo?: 'A' | 'B' | 'C' | 'M' | 'E';
  licencia_numero: bigint;
  licencia_vencimiento?: Date;
  licencia_antiguedad?: number;
  fecha_nacimiento?: Date;
  etnia?: string;
}

export const PilotoModel = {
  // Buscar por número de licencia
  async findByLicencia(licenciaNumero: bigint): Promise<Piloto | null> {
    return db.oneOrNone(
      `SELECT * FROM piloto WHERE licencia_numero = $1`,
      [licenciaNumero]
    );
  },

  // Buscar por ID
  async findById(id: number): Promise<Piloto | null> {
    return db.oneOrNone(
      `SELECT * FROM piloto WHERE id = $1`,
      [id]
    );
  },

  // Crear o actualizar piloto (upsert por licencia)
  async upsert(data: CreatePilotoDTO): Promise<Piloto> {
    return db.one(
      `INSERT INTO piloto (
        nombre, licencia_tipo, licencia_numero, licencia_vencimiento,
        licencia_antiguedad, fecha_nacimiento, etnia
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (licencia_numero) DO UPDATE SET
        nombre = EXCLUDED.nombre,
        licencia_tipo = EXCLUDED.licencia_tipo,
        licencia_vencimiento = EXCLUDED.licencia_vencimiento,
        licencia_antiguedad = EXCLUDED.licencia_antiguedad,
        fecha_nacimiento = EXCLUDED.fecha_nacimiento,
        etnia = EXCLUDED.etnia,
        updated_at = NOW()
      RETURNING *`,
      [
        data.nombre,
        data.licencia_tipo || null,
        data.licencia_numero,
        data.licencia_vencimiento || null,
        data.licencia_antiguedad || null,
        data.fecha_nacimiento || null,
        data.etnia || null
      ]
    );
  },

  // Buscar pilotos con más incidentes
  async findTopByIncidentes(limit: number = 10): Promise<Piloto[]> {
    return db.manyOrNone(
      `SELECT * FROM piloto
       WHERE total_incidentes > 0
       ORDER BY total_incidentes DESC
       LIMIT $1`,
      [limit]
    );
  },

  // Buscar pilotos con más sanciones
  async findTopBySanciones(limit: number = 10): Promise<Piloto[]> {
    return db.manyOrNone(
      `SELECT * FROM piloto
       WHERE total_sanciones > 0
       ORDER BY total_sanciones DESC
       LIMIT $1`,
      [limit]
    );
  },

  // Verificar si la licencia está vencida
  async isLicenciaVencida(licenciaNumero: bigint): Promise<boolean> {
    const piloto = await db.oneOrNone(
      `SELECT licencia_vencimiento FROM piloto
       WHERE licencia_numero = $1`,
      [licenciaNumero]
    );

    if (!piloto || !piloto.licencia_vencimiento) {
      return false;
    }

    return new Date(piloto.licencia_vencimiento) < new Date();
  },

  // Buscar pilotos con licencias próximas a vencer (en los próximos N días)
  async findLicenciasProximasVencer(dias: number = 30): Promise<Piloto[]> {
    return db.manyOrNone(
      `SELECT * FROM piloto
       WHERE licencia_vencimiento IS NOT NULL
         AND licencia_vencimiento BETWEEN NOW() AND NOW() + INTERVAL '${dias} days'
       ORDER BY licencia_vencimiento ASC`,
      []
    );
  }
};
