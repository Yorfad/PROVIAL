import { db } from '../config/database';

export interface Usuario {
  id: number;
  uuid: string;
  username: string;
  password_hash: string;
  nombre_completo: string;
  email: string | null;
  telefono: string | null;
  rol_id: number;
  rol_nombre?: string; // Agregado por JOIN
  sede_id: number | null;
  sede_nombre?: string; // Agregado por JOIN
  activo: boolean;
  ultimo_acceso: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUsuarioDTO {
  username: string;
  password_hash: string;
  nombre_completo: string;
  email?: string;
  telefono?: string;
  rol_id: number;
  sede_id?: number;
}

export const UsuarioModel = {
  // Buscar por username
  async findByUsername(username: string): Promise<Usuario | null> {
    return db.oneOrNone(
      `SELECT u.*,  r.nombre as rol_nombre, s.nombre as sede_nombre
       FROM usuario u
       JOIN rol r ON u.rol_id = r.id
       LEFT JOIN sede s ON u.sede_id = s.id
       WHERE u.username = $1`,
      [username]
    );
  },

  // Buscar por ID
  async findById(id: number): Promise<Usuario | null> {
    return db.oneOrNone(
      `SELECT u.*, r.nombre as rol_nombre, s.nombre as sede_nombre
       FROM usuario u
       JOIN rol r ON u.rol_id = r.id
       LEFT JOIN sede s ON u.sede_id = s.id
       WHERE u.id = $1`,
      [id]
    );
  },

  // Crear usuario
  async create(data: CreateUsuarioDTO): Promise<Usuario> {
    return db.one(
      `INSERT INTO usuario (username, password_hash, nombre_completo, email, telefono, rol_id, sede_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [data.username, data.password_hash, data.nombre_completo, data.email, data.telefono, data.rol_id, data.sede_id]
    );
  },

  // Actualizar último acceso
  async updateLastAccess(id: number): Promise<void> {
    await db.none(
      'UPDATE usuario SET ultimo_acceso = NOW() WHERE id = $1',
      [id]
    );
  },

  // Obtener todos los usuarios (para admin)
  async findAll(): Promise<Usuario[]> {
    return db.any(
      `SELECT u.*, r.nombre as rol_nombre, s.nombre as sede_nombre
       FROM usuario u
       JOIN rol r ON u.rol_id = r.id
       LEFT JOIN sede s ON u.sede_id = s.id
       ORDER BY u.created_at DESC`
    );
  },

  // Actualizar usuario
  async update(id: number, data: Partial<CreateUsuarioDTO>): Promise<Usuario> {
    const fields = Object.keys(data)
      .map((key, idx) => `${key} = $${idx + 2}`)
      .join(', ');
    const values = [id, ...Object.values(data)];

    return db.one(
      `UPDATE usuario SET ${fields}, updated_at = NOW()
       WHERE id = $1
       RETURNING *`,
      values
    );
  },
};
