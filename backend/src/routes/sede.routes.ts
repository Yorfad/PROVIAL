import { Router } from 'express';
import {
  getSedes,
  getSede,
  getUnidadesDeSede,
  getPersonalDeSede,
  getMiSede,
  crearReasignacion,
  getReasignacionesActivas,
  finalizarReasignacion
} from '../controllers/sede.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// ========================================
// CONSULTAS DE SEDES
// ========================================

// Obtener todas las sedes activas
router.get('/', authenticate, getSedes);

// Mi sede efectiva (considerando reasignaciones)
router.get('/mi-sede', authenticate, getMiSede);

// Obtener información de una sede específica
router.get('/:id', authenticate, getSede);

// Obtener unidades de una sede
router.get('/:id/unidades', authenticate, getUnidadesDeSede);

// Obtener personal de una sede
router.get('/:id/personal', authenticate, getPersonalDeSede);

// ========================================
// REASIGNACIONES
// ========================================

// Obtener reasignaciones activas
router.get('/reasignaciones/activas', authenticate, getReasignacionesActivas);

// Crear reasignación (requiere permisos sobre sede origen)
router.post('/reasignaciones', authenticate, authorize('OPERACIONES', 'COP'), crearReasignacion);

// Finalizar reasignación
router.post('/reasignaciones/:id/finalizar', authenticate, authorize('OPERACIONES', 'COP'), finalizarReasignacion);

export default router;
