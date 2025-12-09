import { Request, Response } from 'express';
import { db } from '../config/database';

// GET /api/brigadas - Listar todas las brigadas (usuarios con rol BRIGADA)
export async function listarBrigadas(req: Request, res: Response) {
  try {
    const { sede_id, activa, search } = req.query;

    let query = `
      SELECT
        u.id,
        u.chapa,
        u.nombre_completo as nombre,
        u.telefono,
        u.email,
        u.sede_id,
        s.nombre as sede_nombre,
        u.grupo,
        u.activo as activa,
        u.rol_brigada,
        u.created_at
      FROM usuario u
      JOIN sede s ON u.sede_id = s.id
      JOIN rol r ON u.rol_id = r.id
      WHERE r.nombre = 'BRIGADA'
    `;
    const params: any[] = [];
    let paramCount = 0;

    if (sede_id) {
      params.push(sede_id);
      query += ` AND u.sede_id = $${++paramCount}`;
    }

    if (activa !== undefined) {
      params.push(activa === 'true');
      query += ` AND u.activo = $${++paramCount}`;
    }

    if (search) {
      params.push(`%${search}%`);
      query += ` AND (u.nombre_completo ILIKE $${++paramCount} OR u.chapa ILIKE $${paramCount})`;
    }

    query += ' ORDER BY u.nombre_completo';

    const brigadas = await db.manyOrNone(query, params);
    return res.json({ brigadas, total: brigadas.length });
  } catch (error) {
    console.error('Error en listarBrigadas:', error);
    return res.status(500).json({ error: 'Error al listar brigadas' });
  }
}

// GET /api/brigadas/:id - Obtener una brigada
export async function obtenerBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const brigada = await db.oneOrNone(`
      SELECT
        u.id,
        u.chapa,
        u.nombre_completo as nombre,
        u.telefono,
        u.email,
        u.sede_id,
        s.nombre as sede_nombre,
        u.grupo,
        u.activo as activa,
        u.rol_brigada,
        u.created_at
      FROM usuario u
      JOIN sede s ON u.sede_id = s.id
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    return res.json(brigada);
  } catch (error) {
    console.error('Error en obtenerBrigada:', error);
    return res.status(500).json({ error: 'Error al obtener brigada' });
  }
}

// POST /api/brigadas - Crear brigada (nuevo usuario con rol BRIGADA)
export async function crearBrigada(req: Request, res: Response) {
  try {
    const {
      chapa,
      nombre,
      sede_id,
      telefono,
      email,
      grupo,
      rol_brigada
    } = req.body;

    if (!chapa || !nombre || !sede_id) {
      return res.status(400).json({ error: 'Chapa, nombre y sede_id son requeridos' });
    }

    // Verificar que no exista la chapa
    const existe = await db.oneOrNone('SELECT id FROM usuario WHERE chapa = $1', [chapa]);
    if (existe) {
      return res.status(409).json({ error: 'Ya existe un usuario con esa chapa' });
    }

    // Obtener rol BRIGADA
    const rolBrigada = await db.one("SELECT id FROM rol WHERE nombre = 'BRIGADA'");

    // password123 - hash bcrypt
    const passwordHash = '$2a$10$4iU3aBD9Xbl2jPuGqIejme7Mcu0X7XMocqnfW7yhu9f2ku8hu65Xm';

    const brigada = await db.one(`
      INSERT INTO usuario (username, password_hash, nombre_completo, email, telefono, rol_id, sede_id, chapa, grupo, rol_brigada)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $1, $8, $9)
      RETURNING id, chapa, nombre_completo as nombre, telefono, email, sede_id, grupo, rol_brigada, activo as activa
    `, [chapa, passwordHash, nombre, email, telefono, rolBrigada.id, sede_id, grupo, rol_brigada]);

    return res.status(201).json({ message: 'Brigada creada exitosamente', brigada });
  } catch (error: any) {
    console.error('Error en crearBrigada:', error);
    if (error.code === '23505') {
      return res.status(409).json({ error: 'La chapa o email ya existe' });
    }
    return res.status(500).json({ error: 'Error al crear brigada' });
  }
}

// PUT /api/brigadas/:id - Actualizar brigada
export async function actualizarBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const {
      nombre,
      sede_id,
      telefono,
      email,
      grupo,
      rol_brigada
    } = req.body;

    const brigada = await db.oneOrNone(`
      SELECT u.id FROM usuario u
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    const result = await db.one(`
      UPDATE usuario SET
        nombre_completo = COALESCE($1, nombre_completo),
        sede_id = COALESCE($2, sede_id),
        telefono = COALESCE($3, telefono),
        email = COALESCE($4, email),
        grupo = COALESCE($5, grupo),
        rol_brigada = COALESCE($6, rol_brigada)
      WHERE id = $7
      RETURNING id, chapa, nombre_completo as nombre, telefono, email, sede_id, grupo, rol_brigada, activo as activa
    `, [nombre, sede_id, telefono, email, grupo, rol_brigada, id]);

    return res.json({ message: 'Brigada actualizada exitosamente', brigada: result });
  } catch (error) {
    console.error('Error en actualizarBrigada:', error);
    return res.status(500).json({ error: 'Error al actualizar brigada' });
  }
}

// PUT /api/brigadas/:id/desactivar - Desactivar brigada
export async function desactivarBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const brigada = await db.oneOrNone(`
      SELECT u.id FROM usuario u
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    await db.none('UPDATE usuario SET activo = false WHERE id = $1', [id]);

    return res.json({ message: 'Brigada desactivada exitosamente' });
  } catch (error) {
    console.error('Error en desactivarBrigada:', error);
    return res.status(500).json({ error: 'Error al desactivar brigada' });
  }
}

// PUT /api/brigadas/:id/activar - Activar brigada
export async function activarBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const brigada = await db.oneOrNone(`
      SELECT u.id FROM usuario u
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    await db.none('UPDATE usuario SET activo = true WHERE id = $1', [id]);

    return res.json({ message: 'Brigada activada exitosamente' });
  } catch (error) {
    console.error('Error en activarBrigada:', error);
    return res.status(500).json({ error: 'Error al activar brigada' });
  }
}

// PUT /api/brigadas/:id/transferir - Transferir brigada a otra sede
export async function transferirBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { nueva_sede_id, motivo } = req.body;

    if (!nueva_sede_id) {
      return res.status(400).json({ error: 'nueva_sede_id es requerido' });
    }

    const brigada = await db.oneOrNone(`
      SELECT u.id, u.sede_id FROM usuario u
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    // Verificar que la nueva sede existe
    const sede = await db.oneOrNone('SELECT id FROM sede WHERE id = $1', [nueva_sede_id]);
    if (!sede) {
      return res.status(404).json({ error: 'Sede destino no encontrada' });
    }

    // Solo actualizar la sede del usuario (sin registrar en reasignacion_sede por ahora)
    await db.none('UPDATE usuario SET sede_id = $1 WHERE id = $2', [nueva_sede_id, id]);

    return res.json({ message: 'Brigada transferida exitosamente' });
  } catch (error) {
    console.error('Error en transferirBrigada:', error);
    return res.status(500).json({ error: 'Error al transferir brigada' });
  }
}

// DELETE /api/brigadas/:id - Eliminar brigada (solo si no tiene historial)
export async function eliminarBrigada(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const brigada = await db.oneOrNone(`
      SELECT u.id FROM usuario u
      JOIN rol r ON u.rol_id = r.id
      WHERE u.id = $1 AND r.nombre = 'BRIGADA'
    `, [id]);

    if (!brigada) {
      return res.status(404).json({ error: 'Brigada no encontrada' });
    }

    // Verificar que no tenga historial
    const tieneHistorial = await db.oneOrNone(`
      SELECT 1 FROM tripulacion_turno WHERE usuario_id = $1 LIMIT 1
    `, [id]);

    if (tieneHistorial) {
      return res.status(400).json({
        error: 'No se puede eliminar la brigada porque tiene historial de turnos. Use desactivar en su lugar.'
      });
    }

    // Eliminar brigada_unidad asociaciones
    await db.none('DELETE FROM brigada_unidad WHERE brigada_id = $1', [id]);

    // Eliminar usuario
    await db.none('DELETE FROM usuario WHERE id = $1', [id]);

    return res.json({ message: 'Brigada eliminada exitosamente' });
  } catch (error) {
    console.error('Error en eliminarBrigada:', error);
    return res.status(500).json({ error: 'Error al eliminar brigada' });
  }
}
