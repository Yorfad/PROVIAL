import { db } from '../config/database';

export interface Aseguradora {
  id: number;
  nombre: string;
  codigo: string | null;
  telefono: string | null;
  email: string | null;
  total_incidentes: number;
  activa: boolean;
  created_at: Date;
}

export interface CreateAseguradoraDTO {
  nombre: string;
  codigo?: string;
  telefono?: string;
  email?: string;
}

export const AseguradoraModel = {
  // Buscar por nombre
  async findByNombre(nombre: string): Promise<Aseguradora | null> {
    return db.oneOrNone(
      `SELECT * FROM aseguradora WHERE nombre = $1`,
      [nombre]
    );
  },

  // Buscar por ID
  async findById(id: number): Promise<Aseguradora | null> {
    return db.oneOrNone(
      `SELECT * FROM aseguradora WHERE id = $1`,
      [id]
    );
  },

  // Crear o actualizar aseguradora (upsert por nombre)
  async upsert(data: CreateAseguradoraDTO): Promise<Aseguradora> {
    return db.one(
      `INSERT INTO aseguradora (nombre, codigo, telefono, email)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (nombre) DO UPDATE SET
         codigo = EXCLUDED.codigo,
         telefono = EXCLUDED.telefono,
         email = EXCLUDED.email
       RETURNING *`,
      [data.nombre, data.codigo || null, data.telefono || null, data.email || null]
    );
  },

  // Listar todas las aseguradoras activas
  async findAllActive(): Promise<Aseguradora[]> {
    return db.manyOrNone(
      `SELECT * FROM aseguradora
       WHERE activa = TRUE
       ORDER BY nombre ASC`,
      []
    );
  },

  // Buscar aseguradoras con más incidentes
  async findTopByIncidentes(limit: number = 10): Promise<Aseguradora[]> {
    return db.manyOrNone(
      `SELECT * FROM aseguradora
       WHERE total_incidentes > 0
       ORDER BY total_incidentes DESC
       LIMIT $1`,
      [limit]
    );
  },

  // Desactivar aseguradora
  async deactivate(id: number): Promise<boolean> {
    const result = await db.result(
      `UPDATE aseguradora SET activa = FALSE WHERE id = $1`,
      [id]
    );
    return result.rowCount > 0;
  },

  // Activar aseguradora
  async activate(id: number): Promise<boolean> {
    const result = await db.result(
      `UPDATE aseguradora SET activa = TRUE WHERE id = $1`,
      [id]
    );
    return result.rowCount > 0;
  }
};
