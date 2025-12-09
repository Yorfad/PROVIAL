import { Router } from 'express';
import {
  listarBrigadas,
  obtenerBrigada,
  crearBrigada,
  actualizarBrigada,
  desactivarBrigada,
  activarBrigada,
  transferirBrigada,
  eliminarBrigada
} from '../controllers/brigadas.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// Listar brigadas (Operaciones, Admin)
router.get('/', authenticate, authorize('OPERACIONES', 'ADMIN'), listarBrigadas);

// Obtener brigada específica
router.get('/:id', authenticate, authorize('OPERACIONES', 'ADMIN'), obtenerBrigada);

// Crear brigada (Admin)
router.post('/', authenticate, authorize('ADMIN'), crearBrigada);

// Actualizar brigada
router.put('/:id', authenticate, authorize('OPERACIONES', 'ADMIN'), actualizarBrigada);

// Desactivar brigada
router.put('/:id/desactivar', authenticate, authorize('OPERACIONES', 'ADMIN'), desactivarBrigada);

// Activar brigada
router.put('/:id/activar', authenticate, authorize('OPERACIONES', 'ADMIN'), activarBrigada);

// Transferir brigada a otra sede
router.put('/:id/transferir', authenticate, authorize('OPERACIONES', 'ADMIN'), transferirBrigada);

// Eliminar brigada (solo si no tiene historial)
router.delete('/:id', authenticate, authorize('ADMIN'), eliminarBrigada);

export default router;
